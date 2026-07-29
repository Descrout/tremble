## 1.2.0

* Big structural changes. You might need to rename some imports. ``[BREAKING]``
* ``SignalValue`` added and ``SignalBuilder`` changed to ``SignalValueBuilder``.
* ``RigidBody``, ``CollisionResolver``, ``SpatialHash``, ``Raycaster`` introduced.
* ``AABB``, ``Circle`` and ``Line`` classes got a ``draw(canvas, color)`` function.
* ``draw`` function added to ``Vec2``.
* ``.circle`` getter added to ``AABB`` and ``.aabb`` getter added to ``Sprite``.

## 1.0.24

* ``Animation`` setAnimation will now instantly change frame.

## 1.0.23

* ``Animation`` class improvements and renames. (See docs)
* ``inflate`` and ``deflate`` added to ``AABB``.
* ``randWeightedPick`` and ``randWeightedTake`` added to ``MathUtils``.

## 1.0.22

* ``reverse`` and ``mode`` removed from ``AnimationData`` it is instead added to ``Animation`` itself.

## 1.0.21

* ``AnimationData`` ``loop`` replaced with bunch of animation modes, see ``AnimMode`` enum.
* ``moveTowards`` and ``damp`` functions added to ``MathUtils``.
* ``Spring1D`` and ``Spring2D`` added.

## 1.0.20

* ``SpriteBatch`` getAnimation function now gets single textures if it doesn't find any animation frames.

## 1.0.19

* Multiple page texture atlas support added to ``SpriteBatch``.
* ``Signal`` improvements.
* ``StateMachine`` now clears the ``onBeforeStateChange`` and ``onAfterStateChange`` upon calling ``clear()``

## 1.0.18

* ``\n`` windows split bug fixed.

## 1.0.17

* ``StateMachine`` updated.
* ``Animation`` updated.

## 1.0.16

* ``SpriteBatch`` performance increased.
* ``Camera`` added.
* ``Vector2`` improved and renamed to ``Vec2``.
* ``AABB``, ``Circle``, ``Line`` classes added.
* ``CollisionDetector`` added.
* Example updated.

## 1.0.15

* Documentation added.

## 1.0.14

* ``saveImage`` and ``generateMasked`` functions added to ``ImageUtils``.
* A boolean ``mask`` field added to ``Sprite`` class.

## 1.0.13

* ``randTake`` added to MathUtils.

## 1.0.12

* ``normalizeAngle`` and ``lerpAngle`` added to ``MathUtils`` class.

## 1.0.11

* ``Tween`` class introduced.

## 1.0.10

* ``Parametrics`` class added with bunch of 1d nonlinear functions. (Tweening)
* ``Vector2`` class added.
* ``SecondOrderDynamics`` class added.

## 1.0.9

* ``reset`` function added to the ``StateMachine``.
* You can set the initial state of ``StateMachine`` now.

## 1.0.8

* ``WaitEvents`` clear bug fixed.

## 1.0.7

* ``ColorUtils`` introduced.
* ``onBeforeStateChange`` and ``onAfterStateChange`` callbacks added to ``StateMachine``.
* ``resetState`` function renamed to ``restartState``.

## 1.0.6

* Generic ``StateMachine`` implemented.

## 1.0.5

* ``Statemachine:`` The bug that caused the previous state to be lost when assigning the current state to itself has been resolved.
* ``Statemachine:`` ``reset`` function added.

## 1.0.4

* Added ``periodic`` function to the both ``WaitChainBuilder`` and ``WaitEvents``.

## 1.0.3

* Added ``blockUntil`` function to the ``WaitChainBuilder``.
* ``SpriteBatch`` render performance increased.

## 1.0.2

* Added the ``WaitChainBuilder`` class to make ``WaitEvents`` easier to use. It allows you to create game cinematics more easily.

## 1.0.1

* Documentation updated.

## 1.0.0

* Initial release.