# README

The `StubComponents` folder serves to hold placeholder components that are yet to be implemented.

## Rules

1. The `StubComponents` folder will contain mirrored file names of the components in `Components`. Therefore, it is possible that this `StubFolder` will contain more components since the `Components` folder might not have them implemented yet.

This mirroring approach lets us to use the stub and real components making it easier to switch to the real one by removing the import for the stub ones.

2. Once a component has been implemented, its stub version will be renamed by appending `Stub` before it. E.g. `StubButton`.

This makes it so we still have access to the original skeleton stub component.
