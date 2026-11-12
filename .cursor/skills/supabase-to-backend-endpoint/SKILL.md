---
name: supabase-to-backend-endpoint
description: Convert frontend Supabase client calls (.from(), .rpc()) into backend Express API endpoints with RLS, update the frontend to use the new endpoint via react-query hooks, and add backend unit tests. Use when migrating a direct Supabase call from the web client to a backend route, or when the user asks to move a Supabase query behind the API.
---

# Supabase-to-Backend Endpoint Migration

Moves a direct `supabase.from()` / `supabase.rpc()` call out of the web client into a backend Express endpoint, wires up the frontend to call the new API via react-query, and adds unit tests.

## Workflow

Copy this checklist and track progress:

```
Migration Progress:
- [ ] Step 1: Identify the Supabase call to migrate
- [ ] Step 2: Create backend model
- [ ] Step 3: Create backend service
- [ ] Step 4: Create backend controller
- [ ] Step 5: Create backend route and mount it
- [ ] Step 6: Create frontend API module
- [ ] Step 7: Create/update frontend react-query hook
- [ ] Step 8: Update component to use the hook
- [ ] Step 9: Add backend unit tests
- [ ] Step 10: Verify lints pass
```

---

## Step 1: Identify the Supabase Call

Locate the `supabase.from('table')` or `supabase.rpc('fn')` call in the web client. Determine:

- **Table/function** being accessed
- **Operation**: select → GET, insert → POST, update/upsert → PUT or PATCH, delete → DELETE
- **Filters / params** (`.eq()`, `.in()`, args) — these become query params (GET) or body fields (POST/PUT/PATCH)
- **Who calls it** (component or existing hook)

### HTTP verb mapping

| Supabase method | HTTP verb |
|-----------------|-----------|
| `.select()` | GET |
| `.insert()` | POST |
| `.upsert()` | PUT |
| `.update()` | PATCH |
| `.delete()` | DELETE |
| `.rpc()` (read) | GET |
| `.rpc()` (write) | POST |

---

## Step 2: Create Backend Model

**Path:** `backend/src/apps/<feature>/models/<feature>Model.ts`

Use `req.supabaseClient` (passed from controller → service → model) when Supabase-JS + PostgREST RLS is needed. Use `db` from `../../../lib/prisma` when Prisma + tenant RLS is appropriate.

**When to use which:**
- **`req.supabaseClient`** — the call uses `.rpc()`, realtime, storage, or relies on PostgREST-level RLS policies. The client is created per-request with the caller's JWT and enforces RLS automatically.
- **`db` (Prisma)** — standard CRUD on tables where the `runWithTenantClient` middleware already sets the Postgres session. Prefer this for new table access unless there's a reason to use Supabase-JS.

```typescript
// Example using Supabase client (RLS via JWT)
import { SupabaseClient } from '@supabase/supabase-js';

export async function getItems(supabase: SupabaseClient, userId: string) {
  const { data, error } = await supabase
    .from('items')
    .select('*')
    .eq('user_id', userId);
  if (error) throw error;
  return data;
}
```

```typescript
// Example using Prisma (RLS via tenant session)
import { db } from '../../../lib/prisma';

export async function getItems(userId: string) {
  return db.items.findMany({
    where: { user_id: userId, deleted_at: null },
  });
}
```

---

## Step 3: Create Backend Service

**Path:** `backend/src/apps/<feature>/services/<feature>Service.ts`

Thin orchestration layer. Receives user ID (and `supabaseClient` if needed), calls model, applies business rules.

```typescript
import * as model from '../models/<feature>Model';

export async function getItems(userId: string) {
  return model.getItems(userId);
}
```

---

## Step 4: Create Backend Controller

**Path:** `backend/src/apps/<feature>/controllers/<feature>Controller.ts`

Validates input, reads `req.user`, reads `req.supabaseClient` when the model needs it, calls service, sends response.

```typescript
import { NextFunction, Request, Response } from 'express';
import ApiError from '../../../utils/ApiError';
import * as service from '../services/<feature>Service';

export const getItems = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = await service.getItems(req.user!.id);
    res.json(data);
  } catch (e) {
    next(e);
  }
};

export const deleteItem = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await service.deleteItem(req.user!.id, req.params.itemId);
    res.status(200).json({ success: true });
  } catch (e) {
    next(e);
  }
};
```

**DELETE convention:** return `200` with `{ success: true }` so callers can confirm the operation succeeded.

Use `ApiError` from `../../../utils/ApiError` for validation failures (status 400) and not-found (404).

---

## Step 5: Create Route and Mount

**Route file:** `backend/src/apps/<feature>/routes/index.ts`

```typescript
import express from 'express';
import * as ctrl from '../controllers/<feature>Controller';

const router = express.Router();

router.get('/', ctrl.getItems);
router.post('/', ctrl.createItem);
router.put('/:id', ctrl.updateItem);
router.delete('/:id', ctrl.deleteItem);

export default router;
```

**Mount in `backend/src/index.ts`:** add the import at the top with other route imports, then mount **below** `app.use(asyncHandler(authMiddleware))` so the route is auth-protected:

```typescript
app.use('/api/<feature>', featureRoutes);
```

---

## Step 6: Create Frontend API Module

**Path:** `web/src/apis/<feature>.ts`

Use the existing `api` wrapper from `./wrapper`. Each function maps to one endpoint.

```typescript
import { api } from './wrapper';

export const featureApi = {
  getItems: (sessionId: number) =>
    api.get<Item[]>('/feature', { params: { sessionId: String(sessionId) } }),

  createItem: (payload: CreateItemPayload) =>
    api.post<Item>('/feature', payload),

  updateItem: (id: string, payload: UpdateItemPayload) =>
    api.put<Item>(`/feature/${id}`, payload),

  deleteItem: (id: string) =>
    api.delete<{ success: boolean }>(`/feature/${id}`),
};
```

---

## Step 7: Create Frontend React-Query Hook

**Path:** colocate with the feature — `web/src/hooks/<feature>/use<Feature>.ts` or `web/src/pages/<Page>/hooks/use<Feature>.ts`.

All JS/TS logic lives in hooks per project convention.

### Read (useQuery)

```typescript
import { useQuery } from '@tanstack/react-query';
import { useUserStore } from '@/store/userStore';
import { featureApi } from '@/apis/feature';

export function useFeatureItems(sessionId: number | undefined) {
  const user = useUserStore((s) => s.user);

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['featureItems', user?.id, sessionId],
    queryFn: () => featureApi.getItems(sessionId!),
    enabled: !!user?.id && !!sessionId,
  });

  return { items: data ?? [], isLoading, error, refetch };
}
```

### Write (useMutation + invalidation)

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { featureApi } from '@/apis/feature';

export function useDeleteFeatureItem() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => featureApi.deleteItem(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['featureItems'] });
    },
  });
}
```

Combine read and write into a single hook when they share query keys and the component needs both.

---

## Step 8: Update the Component

Replace the direct Supabase import and inline call with the hook:

```typescript
// Before
import { supabase } from '@/lib/supabase';
// ... supabase.from('items').select(...) inside component

// After
import { useFeatureItems } from '@/hooks/feature/useFeatureItems';
// ... const { items, isLoading } = useFeatureItems(sessionId);
```

Remove the `supabase` import from the file if no other Supabase calls remain.

---

## Step 9: Add Backend Unit Tests

**Path:** `backend/tests/unit/apps/<feature>/`

Create two test files following existing patterns:

### Controller test (`<feature>Controller.test.ts`)

Mock the service module. Test:
- Correct service call with expected args from `req`
- HTTP status codes (200 for GET, 201 for POST, 200 with `{ success: true }` for DELETE)
- Validation errors call `next()` with an `ApiError`

```typescript
import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import ApiError from '../../../../src/utils/ApiError';

const mockGetItems = jest.fn();
const mockDeleteItem = jest.fn();

jest.mock('../../../../src/apps/<feature>/services/<feature>Service', () => ({
  getItems: mockGetItems,
  deleteItem: mockDeleteItem,
}));

import * as ctrl from '../../../../src/apps/<feature>/controllers/<feature>Controller';

function createResponse() {
  const res: any = {};
  res.status = jest.fn(() => res);
  res.json = jest.fn(() => res);
  res.end = jest.fn(() => res);
  return res;
}

function createRequest(overrides: Record<string, any> = {}) {
  return {
    body: {},
    params: {},
    query: {},
    user: { id: 'user-1' },
    supabaseClient: {},
    ...overrides,
  } as any;
}

describe('<feature>Controller', () => {
  const next = jest.fn();
  beforeEach(() => jest.clearAllMocks());

  // test cases...
});
```

### Service test (`<feature>Service.test.ts`)

Mock the model module. Test business logic, edge cases, error mapping.

---

## Step 10: Verify

- Run `ReadLints` on all edited/created files.
- Ensure no leftover `supabase` imports in migrated component/hook.
- Confirm the route is mounted after `authMiddleware` in `backend/src/index.ts`.

---

## Reference: Key File Paths

| Concern | Path |
|---------|------|
| Backend entry / route mounting | `backend/src/index.ts` |
| Auth middleware (sets `req.user`, `req.supabaseClient`) | `backend/src/middleware/authMiddleware.ts` |
| Async handler wrapper | `backend/src/middleware/asyncHandler.ts` |
| Supabase client factory | `backend/src/lib/supabase.ts` |
| Prisma tenant client | `backend/src/lib/prisma.ts` |
| ApiError class | `backend/src/utils/ApiError.ts` |
| Express type augmentation (`req.user`, `req.supabaseClient`) | `backend/src/types/express/index.d.ts` |
| Frontend API wrapper (`api.get/post/put/patch/delete`) | `web/src/apis/wrapper.ts` |
| Frontend Supabase singleton | `web/src/lib/supabase.ts` |
| Backend unit test location | `backend/tests/unit/apps/<feature>/` |
| Backend jest config | `backend/jest.config.js` |
