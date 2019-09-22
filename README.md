AppKitUtilOutlineSelectionTracking
==========================




`NSOutlineView` Pitfalls
------------------------------
Generally, only end-user feasible actions are accepted.
Here are some examples. See also `NSOutlineViewPitfallTests`.

- For expanding/collapsing state, user's intention and final visibility is two different factors.
    - You set to expand/collapse `NSOutlineView` remebers it.
    - But when you query on it, it reports just its current status.
    - For example, if you expand all subtree and collapse the top-level parent only.
        - `NSOutlineView` remembers that you didn't collapsed descendants.
        - They will stay expanded when you expand the collapsed top-level parent again.
        - But if you query on `NSOutlineView`, it'll report all of them collapsed.

- Collapse/expand will be applied immediately and synchronously.

- Root object is always `nil`. But you are supposed to have non-nil root object.
    - This is problematic when you pass parent-object for insert/reload/move/remove.
    - More confusingly, `NSOutlineView` accepts objects that are not in the source tree.
    - And such unknown object will be treated as root object in some cases.
    - And makes an error in some cases...
    
