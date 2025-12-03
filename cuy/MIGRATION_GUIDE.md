# Migration Guide: Tailwind UI HTML to Cuy Components

This guide helps you convert Tailwind UI HTML code into Cuy Phlex components. Follow these steps to systematically migrate your HTML templates.

## Table of Contents

1. [Overview](#overview)
2. [Migration Process](#migration-process)
3. [Component Mapping](#component-mapping)
4. [Common Patterns](#common-patterns)
5. [Step-by-Step Examples](#step-by-step-examples)
6. [Tips & Best Practices](#tips--best-practices)

---

## Overview

### What Changes?

**Before (HTML):**
```html
<div class="overflow-hidden rounded-lg bg-white shadow-sm">
  <div class="px-4 py-5 sm:p-6">
    <h3 class="text-lg font-medium">Card Title</h3>
    <p class="mt-2 text-gray-600">Card content</p>
  </div>
</div>
```

**After (Cuy):**
```ruby
render Cuy::Card.new do
  h3(class: "text-lg font-medium") { "Card Title" }
  p(class: "mt-2 text-gray-600") { "Card content" }
end
```

### Benefits

- ✅ **Type-safe**: Ruby components catch errors at development time
- ✅ **Reusable**: Components can be composed and extended
- ✅ **Maintainable**: Changes in one place update everywhere
- ✅ **Testable**: Components can be unit tested
- ✅ **Rails-aware**: Automatic form helpers, routes, I18n

---

## Migration Process

### Step 1: Identify Components

Scan your HTML and identify which Cuy components map to your markup:

1. **Layout Components**: `Card`, `Container`, `Page`, `Section`
2. **Form Components**: `Input`, `Select`, `RadioGroup`, `CheckboxGroup`, `Toggle`, `Combobox`
3. **Navigation Components**: `Nav`, `Breadcrumb`, `Tabs`
4. **UI Components**: `Button`, `Badge`, `Avatar`, `Modal`, `Toast`

### Step 2: Extract Structure

Identify the component hierarchy:

```html
<!-- Outer container -->
<div class="max-w-7xl mx-auto px-4">
  <!-- Card wrapper -->
  <div class="rounded-lg bg-white shadow-sm">
    <!-- Card header -->
    <div class="border-b px-4 py-5">
      <h3>Title</h3>
    </div>
    <!-- Card body -->
    <div class="px-4 py-5">
      <!-- Form -->
      <form>
        <!-- Input fields -->
      </form>
    </div>
  </div>
</div>
```

### Step 3: Map to Cuy Components

Replace HTML with Cuy components:

```ruby
render Cuy::Container.new(max_width: :xl) do
  render Cuy::Card.new do |card|
    card.header do
      h3 { "Title" }
    end
    
    card.body do
      render Cuy::Form.new(action: "/submit") do |form|
        # Form fields
      end
    end
  end
end
```

### Step 4: Convert Attributes

Map HTML attributes to component options:

| HTML | Cuy |
|------|-----|
| `class="..."` | `class: "..."` or component variant |
| `id="..."` | `id: "..."` |
| `data-*` | `data: { ... }` |
| `aria-*` | `aria: { ... }` |

### Step 5: Test & Refine

1. Compare visual output
2. Test responsive behavior
3. Verify accessibility attributes
4. Check dark mode support

---

## Component Mapping

### Layout Components

#### Card

**HTML:**
```html
<div class="overflow-hidden rounded-lg bg-white shadow-sm">
  <div class="px-4 py-5 sm:p-6">
    Content
  </div>
</div>
```

**Cuy:**
```ruby
render Cuy::Card.new do
  # Content
end
```

**With Header:**
```html
<div class="rounded-lg bg-white shadow-sm">
  <div class="border-b border-gray-200 px-4 py-5 sm:px-6">
    <h3>Header</h3>
  </div>
  <div class="px-4 py-5 sm:p-6">
    Content
  </div>
</div>
```

**Cuy:**
```ruby
render Cuy::Card.new do |card|
  card.header do
    h3 { "Header" }
  end
  
  card.body do
    # Content
  end
end
```

#### Container

**HTML:**
```html
<div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
  Content
</div>
```

**Cuy:**
```ruby
render Cuy::Container.new(max_width: :xl, padding: true) do
  # Content
end
```

### Form Components

#### Input

**HTML:**
```html
<label for="email" class="block text-sm font-medium text-gray-700">
  Email
</label>
<input
  type="email"
  name="email"
  id="email"
  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
  placeholder="you@example.com"
/>
```

**Cuy:**
```ruby
render Cuy::Input.new(
  name: "email",
  type: :email,
  label: "Email",
  placeholder: "you@example.com"
)
```

#### Select

**HTML:**
```html
<label for="country" class="block text-sm font-medium text-gray-700">
  Country
</label>
<select
  id="country"
  name="country"
  class="mt-1 block w-full rounded-md border-gray-300"
>
  <option>United States</option>
  <option>Canada</option>
</select>
```

**Cuy:**
```ruby
render Cuy::Select.new(name: "country", label: "Country") do |select|
  select.option("United States")
  select.option("Canada")
end
```

#### RadioGroup

**HTML:**
```html
<fieldset>
  <legend class="text-base font-medium text-gray-900">Notifications</legend>
  <div class="mt-4 space-y-4">
    <div class="flex items-center">
      <input
        id="email"
        name="notification-method"
        type="radio"
        class="h-4 w-4 border-gray-300"
        checked
      />
      <label for="email" class="ml-3 block text-sm font-medium">
        Email
      </label>
    </div>
  </div>
</fieldset>
```

**Cuy:**
```ruby
render Cuy::RadioGroup.new(
  name: "notification_method",
  legend: "Notifications"
) do |group|
  group.radio("email", "Email", checked: true)
  group.radio("sms", "Phone (SMS)")
end
```

#### CheckboxGroup

**HTML:**
```html
<fieldset>
  <legend class="text-base font-medium text-gray-900">Notifications</legend>
  <div class="mt-4 space-y-4">
    <div class="flex items-center">
      <input
        id="comments"
        name="comments"
        type="checkbox"
        class="h-4 w-4 rounded border-gray-300"
        checked
      />
      <label for="comments" class="ml-3 block text-sm font-medium">
        Comments
      </label>
    </div>
  </div>
</fieldset>
```

**Cuy:**
```ruby
render Cuy::CheckboxGroup.new(legend: "Notifications") do |group|
  group.checkbox("comments", "Comments", checked: true)
  group.checkbox("candidates", "Candidates")
end
```

#### Toggle

**HTML:**
```html
<div class="flex items-center">
  <button
    type="button"
    class="relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-gray-200 transition-colors"
    role="switch"
    aria-checked="false"
  >
    <span class="translate-x-0 pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"></span>
  </button>
  <span class="ml-3">
    <span class="text-sm font-medium text-gray-700">Enable notifications</span>
  </span>
</div>
```

**Cuy:**
```ruby
render Cuy::Toggle.new(
  name: "notifications",
  label: "Enable notifications"
)
```

### Navigation Components

#### Nav

**HTML:**
```html
<nav class="bg-white shadow-sm">
  <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
    <div class="flex h-16 justify-between">
      <div class="flex">
        <a href="/" class="flex items-center">Logo</a>
        <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
          <a href="/dashboard" class="border-indigo-500 text-gray-900 inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium">Dashboard</a>
        </div>
      </div>
    </div>
  </div>
</nav>
```

**Cuy:**
```ruby
render Cuy::Nav.new(current_path: request.path) do |nav|
  nav.logo { a(href: "/") { "Logo" } }
  nav.item("/dashboard") { "Dashboard" }
  nav.item("/team") { "Team" }
end
```

#### Breadcrumb

**HTML:**
```html
<nav aria-label="Breadcrumb">
  <ol class="flex items-center space-x-4">
    <li>
      <a href="/" class="text-gray-400 hover:text-gray-500">Home</a>
    </li>
    <li>
      <span class="text-gray-500">/</span>
    </li>
    <li>
      <a href="/projects" class="text-gray-400 hover:text-gray-500">Projects</a>
    </li>
  </ol>
</nav>
```

**Cuy:**
```ruby
render Cuy::Breadcrumb.new do |breadcrumb|
  breadcrumb.item("/") { "Home" }
  breadcrumb.item("/projects") { "Projects" }
  breadcrumb.item("/projects/123", current: true) { "Project Details" }
end
```

### UI Components

#### Button

**HTML:**
```html
<button
  type="button"
  class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
>
  Button text
</button>
```

**Cuy:**
```ruby
render Cuy::Button.new(variant: :primary) { "Button text" }
```

#### Badge

**HTML:**
```html
<span class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
  Active
</span>
```

**Cuy:**
```ruby
render Cuy::Badge.new(variant: :success) { "Active" }
```

---

## Common Patterns

### Pattern 1: Form with Grid Layout

**HTML:**
```html
<form>
  <div class="grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6">
    <div class="sm:col-span-3">
      <label>First name</label>
      <input type="text" name="first_name" />
    </div>
    <div class="sm:col-span-3">
      <label>Last name</label>
      <input type="text" name="last_name" />
    </div>
  </div>
</form>
```

**Cuy:**
```ruby
render Cuy::Form.new(action: "/users", method: :post) do |form|
  form.grid do |grid|
    grid.field(span: 3) do
      render Cuy::Input.new(name: "first_name", label: "First name")
    end
    grid.field(span: 3) do
      render Cuy::Input.new(name: "last_name", label: "Last name")
    end
  end
end
```

### Pattern 2: Card with Actions

**HTML:**
```html
<div class="rounded-lg bg-white shadow-sm">
  <div class="px-4 py-5 sm:p-6">
    <h3>Title</h3>
    <p>Content</p>
  </div>
  <div class="border-t border-gray-200 px-4 py-4 sm:px-6">
    <button class="rounded-md bg-indigo-600 px-3 py-2 text-sm text-white">
      Save
    </button>
  </div>
</div>
```

**Cuy:**
```ruby
render Cuy::Card.new do |card|
  card.body do
    h3 { "Title" }
    p { "Content" }
  end
  
  card.footer do
    render Cuy::Button.new(variant: :primary) { "Save" }
  end
end
```

### Pattern 3: Responsive Container

**HTML:**
```html
<div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
  <div class="mx-auto max-w-2xl">
    Content
  </div>
</div>
```

**Cuy:**
```ruby
render Cuy::Container.new(max_width: :xl) do
  render Cuy::Container.new(max_width: :md) do
    # Content
  end
end
```

---

## Step-by-Step Examples

### Example 1: Simple Card Migration

**Original HTML:**
```html
<div class="bg-gray-100 dark:bg-gray-900">
  <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-2xl">
      <div class="overflow-hidden rounded-lg bg-white shadow-sm dark:bg-gray-800/50">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg font-medium">Card Title</h3>
          <p class="mt-2 text-gray-600">Card content goes here.</p>
        </div>
      </div>
    </div>
  </div>
</div>
```

**Step 1: Identify components**
- Outer container: `Cuy::Container`
- Card: `Cuy::Card`

**Step 2: Convert to Cuy:**
```ruby
div(class: "bg-gray-100 dark:bg-gray-900") do
  render Cuy::Container.new(max_width: :xl) do
    render Cuy::Container.new(max_width: :md) do
      render Cuy::Card.new do
        h3(class: "text-lg font-medium") { "Card Title" }
        p(class: "mt-2 text-gray-600") { "Card content goes here." }
      end
    end
  end
end
```

### Example 2: Form Migration

**Original HTML:**
```html
<form action="/users" method="post">
  <div class="space-y-6">
    <div>
      <label for="email" class="block text-sm font-medium text-gray-700">
        Email
      </label>
      <div class="mt-1">
        <input
          type="email"
          name="email"
          id="email"
          class="block w-full rounded-md border-gray-300 shadow-sm"
          placeholder="you@example.com"
        />
      </div>
    </div>
    <div>
      <button
        type="submit"
        class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500"
      >
        Save
      </button>
    </div>
  </div>
</form>
```

**Step 1: Identify components**
- Form: `Cuy::Form`
- Input: `Cuy::Input`
- Button: `Cuy::Button`

**Step 2: Convert to Cuy:**
```ruby
render Cuy::Form.new(action: "/users", method: :post) do |form|
  form.field(label: "Email") do
    render Cuy::Input.new(
      name: "email",
      type: :email,
      placeholder: "you@example.com"
    )
  end
  
  form.actions do
    render Cuy::Button.new(type: :submit, variant: :primary) { "Save" }
  end
end
```

### Example 3: Navigation Migration

**Original HTML:**
```html
<nav class="bg-white shadow-sm">
  <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
    <div class="flex h-16 justify-between">
      <div class="flex">
        <a href="/" class="flex items-center">
          <img src="/logo.svg" alt="Logo" class="h-8 w-auto" />
        </a>
        <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
          <a href="/dashboard" class="border-indigo-500 text-gray-900 inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium">Dashboard</a>
          <a href="/team" class="border-transparent text-gray-500 inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium hover:border-gray-300 hover:text-gray-700">Team</a>
        </div>
      </div>
    </div>
  </div>
</nav>
```

**Step 1: Identify components**
- Nav: `Cuy::Nav`

**Step 2: Convert to Cuy:**
```ruby
render Cuy::Nav.new(current_path: request.path) do |nav|
  nav.logo do
    a(href: "/") do
      img(src: "/logo.svg", alt: "Logo", class: "h-8 w-auto")
    end
  end
  
  nav.item("/dashboard") { "Dashboard" }
  nav.item("/team") { "Team" }
end
```

---

## Cuy Guidelines

### ⚠️ Critical Rules

#### 1. **Never Pass `value:` Key - Use Blocks Instead**

**❌ Wrong:**
```ruby
render Cuy::Button.new(value: "Save")
render Cuy::Card.new(value: "Content")
render Cuy::Badge.new(value: "Active")
```

**✅ Correct:**
```ruby
render Cuy::Button.new { "Save" }
render Cuy::Card.new { "Content" }
render Cuy::Badge.new { "Active" }
```

**Why?** Blocks provide flexibility for:
- Dynamic content
- Nested components
- Conditional rendering
- Complex markup

**Example with nested content:**
```ruby
# ❌ Wrong
render Cuy::Button.new(value: "<span>Save</span>")

# ✅ Correct
render Cuy::Button.new do
  span { "Save" }
  svg_icon(:check, class: "ml-2")
end
```

#### 2. **Prefer Composition Over Configuration**

Build complex UIs by composing simple components rather than adding many options.

**❌ Wrong (over-configuration):**
```ruby
render Cuy::Card.new(
  has_header: true,
  header_title: "Title",
  header_actions: [button1, button2],
  has_footer: true,
  footer_actions: [button3]
)
```

**✅ Correct (composition):**
```ruby
render Cuy::Card.new do |card|
  card.header do
    h3 { "Title" }
    div(class: "flex gap-2") do
      render button1
      render button2
    end
  end
  
  card.body do
    # Content
  end
  
  card.footer do
    render button3
  end
end
```

**Why?** Composition:
- More flexible and extensible
- Easier to understand and maintain
- Follows Phlex's block-based philosophy
- Allows conditional rendering

**Another example:**
```ruby
# ❌ Wrong
render Cuy::Form.new(
  fields: [
    { name: "email", type: :email, label: "Email" },
    { name: "name", type: :text, label: "Name" }
  ]
)

# ✅ Correct
render Cuy::Form.new(action: "/users") do |form|
  form.field(label: "Email") do
    render Cuy::Input.new(name: "email", type: :email)
  end
  
  form.field(label: "Name") do
    render Cuy::Input.new(name: "name", type: :text)
  end
end
```

#### 3. **Use Blocks for All Content**

Always use blocks for component content, even for simple text.

**❌ Wrong:**
```ruby
render Cuy::Button.new(text: "Click me")
render Cuy::Card.new(title: "Card Title", content: "Card body")
```

**✅ Correct:**
```ruby
render Cuy::Button.new { "Click me" }
render Cuy::Card.new do
  h3 { "Card Title" }
  p { "Card body" }
end
```

#### 4. **Compose, Don't Configure**

Break down complex components into smaller, composable pieces.

**❌ Wrong:**
```ruby
render Cuy::Page.new(
  navbar: nav_config,
  sidebar: sidebar_config,
  header: header_config,
  main: main_content
)
```

**✅ Correct:**
```ruby
render Cuy::Page.new do |page|
  page.navbar do
    render Cuy::Nav.new(current_path: request.path) do |nav|
      nav.item("/") { "Home" }
      nav.item("/about") { "About" }
    end
  end
  
  page.sidebar do
    render SidebarComponent.new
  end
  
  page.header do
    render Cuy::PageHeader.new(title: "Dashboard")
  end
  
  page.main do
    # Main content
  end
end
```

---

## Tips & Best Practices

### 1. Start Small

Migrate one component at a time. Don't try to convert an entire page at once.

### 2. Preserve Custom Classes

If you have custom Tailwind classes that don't map to Cuy variants, pass them through:

```ruby
render Cuy::Card.new(class: "custom-class") do
  # Content
end
```

### 3. Use Component Variants

Prefer component variants over custom classes when possible:

```ruby
# Good
render Cuy::Button.new(variant: :primary) { "Save" }

# Less ideal (but still works)
render Cuy::Button.new(class: "bg-indigo-600 text-white") { "Save" }
```

### 4. Leverage Rails Helpers

Use Rails helpers for routes, forms, and I18n:

```ruby
render Cuy::Form.new(action: users_path, method: :post) do |form|
  # Form fields
end

render Cuy::Button.new(href: new_user_path) { t("users.new") }
```

### 5. Test Responsive Behavior

Verify that responsive classes (`sm:`, `md:`, `lg:`) are preserved or mapped correctly:

```ruby
# HTML: class="px-4 sm:px-6"
render Cuy::Card.new(padding: { mobile: 4, desktop: 6 })
```

### 6. Check Dark Mode

Ensure dark mode classes are preserved:

```ruby
# HTML: class="bg-white dark:bg-gray-800"
render Cuy::Card.new # Automatically handles dark mode
```

### 7. Maintain Accessibility

Preserve ARIA attributes and semantic HTML:

```ruby
render Cuy::Nav.new(aria: { label: "Main navigation" }) do |nav|
  # Nav items
end
```

### 8. Use Blocks for Content

Prefer blocks over string content for flexibility:

```ruby
# Good
render Cuy::Card.new do
  h3 { user.name }
  p { user.bio }
end

# Less flexible
render Cuy::Card.new(content: "#{user.name} #{user.bio}")
```

### 9. Compose Components

Build complex UIs by composing simple components:

```ruby
render Cuy::Page.new do |page|
  page.navbar do
    render Cuy::Nav.new(current_path: request.path) do |nav|
      # Nav items
    end
  end
  
  page.main do
    render Cuy::Container.new do
      render Cuy::Card.new do
        # Content
      end
    end
  end
end
```

### 10. Document Customizations

If you extend Cuy components, document the changes:

```ruby
# app/components/custom_card.rb
module Components
  class CustomCard < Cuy::Card
    def initialize(**options)
      super(variant: :custom, **options)
    end
  end
end
```

### 11. Keep Components Focused

Each component should have a single responsibility. If you need multiple behaviors, compose multiple components:

```ruby
# ❌ Wrong: One component doing too much
render Cuy::CardWithForm.new(...)

# ✅ Correct: Compose separate components
render Cuy::Card.new do
  render Cuy::Form.new(...) do |form|
    # Form fields
  end
end
```

### 12. Use Conditional Rendering in Blocks

Leverage Ruby's control flow within blocks:

```ruby
render Cuy::Card.new do
  h3 { user.name }
  
  if user.bio.present?
    p(class: "mt-2") { user.bio }
  end
  
  div(class: "mt-4") do
    render Cuy::Button.new { "Edit" } if can_edit?(user)
  end
end
```

---

## Component Reference

For detailed API documentation, see:

- [Components Guide](./COMPONENTS.md) - Complete component reference
- [Form Layouts Guide](./FORM_LAYOUTS.md) - Form-specific patterns
- [Rails Integration Guide](./RAILS_INTEGRATION.md) - Model-aware components

---

## Need Help?

- Check the [README](./README.md) for overview and philosophy
- Review [COMPONENTS.md](./COMPONENTS.md) for API details
- Look at existing components in your codebase for patterns
- Test in Phlexbook (if available) to see component variations

---

## Quick Reference: HTML → Cuy Mapping

| HTML Pattern | Cuy Component |
|-------------|---------------|
| `<div class="rounded-lg bg-white shadow-sm">` | `Cuy::Card.new` |
| `<input type="text" name="...">` | `Cuy::Input.new(name: "...")` |
| `<select name="...">` | `Cuy::Select.new(name: "...")` |
| `<fieldset><legend>...</legend>` | `Cuy::RadioGroup.new(legend: "...")` |
| `<button class="bg-indigo-600">` | `Cuy::Button.new(variant: :primary)` |
| `<nav>` | `Cuy::Nav.new` |
| `<div class="max-w-7xl mx-auto">` | `Cuy::Container.new(max_width: :xl)` |
| `<span class="rounded-md bg-green-50">` | `Cuy::Badge.new(variant: :success)` |

---

## Remember: Core Guidelines

1. **Never use `value:` - Always use blocks**
   ```ruby
   # ❌ render Cuy::Button.new(value: "Save")
   # ✅ render Cuy::Button.new { "Save" }
   ```

2. **Prefer composition over configuration**
   ```ruby
   # ❌ render Cuy::Card.new(header: "...", footer: "...")
   # ✅ render Cuy::Card.new do |card|
   #      card.header { ... }
   #      card.footer { ... }
   #    end
   ```

3. **Compose simple components into complex UIs**
   ```ruby
   # ✅ Build with blocks and composition
   render Cuy::Page.new do |page|
     page.navbar { render Cuy::Nav.new(...) }
     page.main { render Cuy::Card.new { ... } }
   end
   ```

---

**Happy Migrating! 🚀**

