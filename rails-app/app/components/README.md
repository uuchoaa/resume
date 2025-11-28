# Components

This folder contains Phlex-based view components used across the application.

- Purpose: small, testable building blocks for UI rendered on the server.
- Base class: `Components::Base` (includes route helpers and `form_authenticity_token`).
- Naming: components live under `Components::` namespace and map to files (e.g. `page_header.rb`).

Conventions
- Each component implements `view_template` (Phlex). Initialize with required data.
- Keep markup and minimal rendering logic in components. Complex behavior belongs in helpers/controllers.
- Private helper methods may be added for clarity and testability.

Attributes components
- Located in `components/attributes/`. These small components render single model attributes
  (e.g. `IdAttribute`, `TimestampAttribute`, `BelongsToAttribute`, `HasManyAttribute`).

Testing
- Components are unit-tested under `test/components` using `.call` to render HTML.
- Fixtures under `test/fixtures` provide sample models for association tests.
- To run only component tests:

  ```bash
  bin/rails test test/components/
  ```

Rendering examples
- Render a component in views or controllers by calling `Components::PageHeader.new("Title").call`.
- Attribute components are used inside component views via `render Components::Attributes::IdAttribute.new(...)`.

Notes
- Components assume normal Rails routing helpers are available via `Components::Base`.
- Keep components focused and small for easier testing and reuse.