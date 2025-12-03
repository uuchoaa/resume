# Form Layouts in Cuy

This document outlines the design philosophy and implementation strategy for flexible, powerful form layouts in Cuy.

## Overview

Forms in Cuy follow a **layered abstraction** approach, providing three levels of control depending on your needs:

1. **Smart Form Builder** - Convention over configuration (80% use case)
2. **Manual Layout Control** - Explicit grid/section control (custom layouts)
3. **Full Phlex Control** - Total freedom (complex/unique cases)

---

## Form Layout Patterns

### Common Patterns We Support

#### 1. Form Sections
Logical grouping with headers, descriptions, and visual separation:

```
┌─────────────────────────────────────────┐
│ Profile                                 │
│ This information will be displayed...   │
├─────────────────────────────────────────┤
│ [Fields...]                             │
└─────────────────────────────────────────┘
```

#### 2. Responsive Grid Layout
Fields that arrange side-by-side on desktop, stack on mobile:

```
Desktop:                Mobile:
┌────────┬────────┐    ┌──────────────┐
│ First  │ Last   │    │ First Name   │
└────────┴────────┘    ├──────────────┤
┌──────────────────┐   │ Last Name    │
│ Email            │    ├──────────────┤
└──────────────────┘   │ Email        │
                       └──────────────┘
```

#### 3. Complex Field Patterns
- Input with leading add-ons (`workcation.com/username`)
- File upload zones with drag-and-drop
- Checkbox/radio groups with descriptions
- Nested fieldsets

#### 4. Form Actions
Cancel and submit buttons with consistent spacing and alignment.

---

## Design Philosophy

### Layer 1: Smart Form Builder (ModelForm)

**When to use:** Standard CRUD forms for ActiveRecord models.

**Philosophy:** Maximum productivity through intelligent defaults.

```ruby
render Cuy::ModelForm.new(@user, url: update_profile_path) do |f|
  f.section("Profile", "This information will be displayed publicly") do
    f.input(:username, addon: "workcation.com/")
    f.textarea(:about, hint: "Write a few sentences about yourself.")
    f.file_field(:photo, preview: :avatar)
    f.file_field(:cover_photo, style: :dropzone)
  end
  
  f.section("Personal Information", "Use a permanent address") do
    f.row do |r|
      r.input(:first_name, span: 3)
      r.input(:last_name, span: 3)
    end
    
    f.input(:email, span: 4)
    f.select(:country, span: 3)
    f.input(:street_address, span: :full)
    
    f.row do |r|
      r.input(:city, span: 2)
      r.input(:region, span: 2)
      r.input(:postal_code, span: 2)
    end
  end
  
  f.section("Notifications") do
    f.checkbox_group(
      legend: "By email",
      name: "email_notifications"
    ) do |group|
      group.checkbox(
        :comments,
        description: "Get notified when someone posts a comment"
      )
      group.checkbox(:candidates)
      group.checkbox(:offers)
    end
    
    f.radio_group(
      legend: "Push notifications",
      hint: "These are delivered via SMS",
      name: "push_notifications"
    ) do |group|
      group.radio(:everything, checked: true)
      group.radio(:email, label: "Same as email")
      group.radio(:nothing, label: "No push notifications")
    end
  end
  
  f.actions do |a|
    a.cancel
    a.submit("Save")
  end
end
```

**Features:**
- ✅ Auto-detects field types from model
- ✅ Handles validation errors automatically
- ✅ Grid layout with responsive defaults
- ✅ Smart `span:` option (`:full`, numbers for grid columns)
- ✅ Built-in section styling with borders
- ✅ Accessible by default

**Grid System:**
- Default: 6-column grid on desktop (`sm:grid-cols-6`)
- Configurable via `cols:` option
- `span:` options: `:full` or numbers (1-6)
- `f.row` groups fields on same row

---

### Layer 2: Manual Layout Control

**When to use:** Custom layouts that don't fit standard patterns, or when you need explicit control.

**Philosophy:** Explicit but ergonomic.

```ruby
render Cuy::Form.new(action: update_profile_path, method: :patch) do |f|
  # Section component with explicit styling control
  render Cuy::Form::Section.new(
    title: "Profile",
    description: "This information will be displayed publicly",
    border: true
  ) do
    # Grid component with explicit column configuration
    render Cuy::Form::Grid.new(
      cols: { base: 1, sm: 6 },
      gap: { x: 6, y: 8 }
    ) do |grid|
      # Column wrapper with span control
      grid.column(span: 4) do
        render Cuy::Input.new(
          name: "username",
          label: "Username"
        ) do |input|
          input.addon("workcation.com/")
        end
      end
      
      grid.column(span: :full) do
        render Cuy::Textarea.new(
          name: "about",
          label: "About",
          hint: "Write a few sentences about yourself.",
          rows: 3
        )
      end
      
      grid.column(span: :full) do
        render Cuy::FileUpload.new(
          name: "cover_photo",
          label: "Cover photo",
          style: :dropzone,
          accept: "image/*",
          hint: "PNG, JPG, GIF up to 10MB"
        )
      end
    end
  end
  
  # Manual section without helper
  div(class: "border-b border-gray-900/10 pb-12 dark:border-white/10") do
    h2(class: "text-base/7 font-semibold") { "Personal Information" }
    p(class: "mt-1 text-sm/6 text-gray-600 dark:text-gray-400") do
      "Use a permanent address where you can receive mail."
    end
    
    render Cuy::Form::Grid.new(cols: { sm: 6 }) do |grid|
      grid.column(span: 3) do
        render Cuy::Input.new(name: "first_name", label: "First name")
      end
      
      grid.column(span: 3) do
        render Cuy::Input.new(name: "last_name", label: "Last name")
      end
    end
  end
  
  # Form actions
  render Cuy::Form::Actions.new(align: :end, gap: 6) do |actions|
    actions.button("Cancel", type: :button, variant: :ghost)
    actions.button("Save", type: :submit, variant: :primary)
  end
end
```

**Components:**

#### `Cuy::Form::Section`
```ruby
Cuy::Form::Section.new(
  title: String,
  description: String | nil,
  border: Boolean (default: true),
  spacing: Symbol (:normal, :tight, :loose)
)
```

#### `Cuy::Form::Grid`
```ruby
Cuy::Form::Grid.new(
  cols: Integer | Hash (e.g., { base: 1, sm: 6 }),
  gap: Integer | Hash (e.g., { x: 6, y: 8 }),
  # Auto-wraps children in column divs
)
```

#### `Cuy::Form::Actions`
```ruby
Cuy::Form::Actions.new(
  align: Symbol (:start, :end, :center, :between),
  gap: Integer
)
```

---

### Layer 3: Full Phlex Control

**When to use:** Completely custom layouts, integration with existing markup, or when you need absolute control.

**Philosophy:** Get out of your way.

```ruby
form(action: update_profile_path, method: :post) do
  div(class: "space-y-12") do
    div(class: "border-b border-gray-900/10 pb-12 dark:border-white/10") do
      h2(class: "text-base/7 font-semibold text-gray-900 dark:text-white") do
        "Profile"
      end
      p(class: "mt-1 text-sm/6 text-gray-600 dark:text-gray-400") do
        "This information will be displayed publicly"
      end
      
      div(class: "mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6") do
        div(class: "sm:col-span-4") do
          label(
            for: "username",
            class: "block text-sm/6 font-medium text-gray-900 dark:text-white"
          ) { "Username" }
          
          div(class: "mt-2") do
            div(class: "flex items-center rounded-md bg-white pl-3 outline outline-1 -outline-offset-1 outline-gray-300 focus-within:outline-2 dark:bg-white/5 dark:outline-white/10") do
              div(class: "shrink-0 select-none text-gray-500 dark:text-gray-400") do
                "workcation.com/"
              end
              
              input(
                id: "username",
                type: "text",
                name: "username",
                class: "block min-w-0 grow py-1.5 pl-1 pr-3 focus:outline-0"
              )
            end
          end
        end
        
        div(class: "col-span-full") do
          render Cuy::Textarea.new(name: "about", label: "About")
        end
      end
    end
  end
  
  div(class: "mt-6 flex items-center justify-end gap-x-6") do
    button(type: "button", class: "text-sm/6 font-semibold") { "Cancel" }
    
    render Cuy::Button.new(type: :submit, variant: :primary) { "Save" }
  end
end
```

**Mix and match:**
- Use Cuy components where helpful
- Drop to raw HTML when needed
- No magic, just Phlex

---

## Component API Reference

### `Cuy::ModelForm`

Smart form builder with Rails model integration.

```ruby
Cuy::ModelForm.new(
  model,                    # ActiveRecord model instance
  url: String | nil,        # Form action (auto-detected if nil)
  method: Symbol,           # :post, :patch, :put (auto-detected)
  layout: Symbol,           # :grid (default), :stacked
  cols: Integer | Hash,     # Grid columns (default: { sm: 6 })
  gap: Integer | Hash,      # Grid gap (default: { x: 6, y: 8 })
  **html_options            # Passed to form tag
)
```

**Methods:**
- `f.section(title, description = nil, **options, &block)`
- `f.row(&block)` - Group fields on same row
- `f.input(name, **options)` - Text input (auto-detects type from model)
- `f.textarea(name, **options)`
- `f.select(name, choices = nil, **options)` - Auto-loads from enum if nil
- `f.checkbox(name, **options)`
- `f.checkbox_group(legend:, name:, **options, &block)`
- `f.radio_group(legend:, name:, **options, &block)`
- `f.file_field(name, **options)`
- `f.actions(&block)` - Yield actions builder

**Span Options:**
All field methods accept `span:` parameter:
- `:full` - Full width
- `1-6` - Number of columns (relative to grid)
- `{ base: :full, sm: 3 }` - Responsive spans

### `Cuy::Form::Section`

Visual grouping with header and description.

```ruby
Cuy::Form::Section.new(
  title: String,
  description: String | nil,
  border: Boolean,          # Show bottom border (default: true)
  spacing: Symbol,          # :normal, :tight, :loose (default: :normal)
  **html_options
)
```

### `Cuy::Form::Grid`

Responsive grid layout for form fields.

```ruby
Cuy::Form::Grid.new(
  cols: Integer | Hash,     # e.g., { base: 1, sm: 6, lg: 12 }
  gap: Integer | Hash,      # e.g., { x: 6, y: 8 } or just 6
  **html_options
)

# Usage
grid.column(span: Integer | :full | Hash, **html_options, &block)
```

### `Cuy::Form::Actions`

Button group for form actions (submit, cancel, etc.).

```ruby
Cuy::Form::Actions.new(
  align: Symbol,            # :start, :end, :center, :between
  gap: Integer,             # Spacing between buttons (default: 6)
  **html_options
)

# Usage
actions.button(text, type: Symbol, variant: Symbol, **options)
actions.cancel(text = "Cancel", **options)
actions.submit(text = "Save", **options)
```

### `Cuy::FileUpload`

File upload with multiple styles.

```ruby
Cuy::FileUpload.new(
  name: String,
  label: String,
  style: Symbol,            # :button, :dropzone (default: :button)
  preview: Symbol | nil,    # :avatar, :image, :document
  accept: String | nil,     # MIME types
  hint: String | nil,       # Help text
  multiple: Boolean,        # Allow multiple files
  **html_options
)
```

---

## Layout Strategies

### Grid System

Cuy uses a **6-column responsive grid** by default (matching Tailwind UI patterns):

```
Mobile (< 640px):          Desktop (≥ 640px):
┌─────────────────┐        ┌───┬───┬───┬───┬───┬───┐
│ Full Width      │        │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
└─────────────────┘        └───┴───┴───┴───┴───┴───┘
```

**Common span patterns:**
- `span: :full` - Full width on all screens
- `span: 4` - 4/6 width on desktop, full on mobile
- `span: 3` - 3/6 width (half) on desktop, full on mobile
- `span: 2` - 2/6 width (third) on desktop, full on mobile

**Responsive spans:**
```ruby
f.input(:username, span: { base: :full, sm: 4, lg: 3 })
```

### Section Spacing

Forms use `space-y-12` between sections by default (48px):

```
Section 1
├─ Header
├─ Description
└─ Fields
────────────────── (48px gap)
Section 2
├─ Header
└─ Fields
────────────────── (48px gap)
Actions
```

Override with `spacing:` option:
- `:tight` - `space-y-6` (24px)
- `:normal` - `space-y-12` (48px, default)
- `:loose` - `space-y-16` (64px)

---

## Examples

### Example 1: Simple Contact Form

```ruby
render Cuy::ModelForm.new(@contact) do |f|
  f.row do |r|
    r.input(:first_name, span: 3)
    r.input(:last_name, span: 3)
  end
  
  f.input(:email, type: :email, span: :full)
  f.textarea(:message, rows: 4)
  
  f.actions { |a| a.submit("Send Message") }
end
```

### Example 2: Multi-Section Profile Form

```ruby
render Cuy::ModelForm.new(@user) do |f|
  f.section("Profile", "Public information") do
    f.input(:username, addon: "myapp.com/")
    f.textarea(:bio)
    f.file_field(:avatar, preview: :avatar)
  end
  
  f.section("Account", "Login credentials") do
    f.input(:email, type: :email)
    f.input(:password, type: :password)
  end
  
  f.actions do |a|
    a.cancel
    a.submit("Update Profile")
  end
end
```

### Example 3: Complex Layout with Custom Grid

```ruby
render Cuy::Form.new(action: create_user_path) do
  render Cuy::Form::Section.new(title: "User Information") do
    render Cuy::Form::Grid.new(cols: { sm: 12 }) do |grid|
      # Custom 12-column grid for more control
      grid.column(span: 4) { render Cuy::Input.new(name: "first_name") }
      grid.column(span: 4) { render Cuy::Input.new(name: "middle_name") }
      grid.column(span: 4) { render Cuy::Input.new(name: "last_name") }
      
      grid.column(span: 8) { render Cuy::Input.new(name: "email") }
      grid.column(span: 4) { render Cuy::Input.new(name: "phone") }
    end
  end
end
```

### Example 4: Inline Form (No Grid)

```ruby
render Cuy::ModelForm.new(@search, layout: :stacked) do |f|
  f.input(:query, hide_label: true, placeholder: "Search...")
  f.actions { |a| a.submit("Search") }
end
```

---

## Design Decisions

### Why Three Layers?

1. **Layer 1 (ModelForm)** handles 80% of forms with minimal code
2. **Layer 2 (Manual)** handles the 15% that need custom layouts
3. **Layer 3 (Phlex)** handles the 5% edge cases and migrations

Most apps will use Layer 1 extensively, occasionally drop to Layer 2, and rarely need Layer 3.

### Why Grid-Based?

- **Responsive by default** - Desktop layouts collapse to mobile automatically
- **Consistent spacing** - Uses Tailwind's spacing scale
- **Matches Tailwind UI** - Familiar patterns for developers
- **Flexible** - Supports custom column counts

### Why Not `form_with` Integration?

We wrap and enhance Rails form helpers but don't replace them. `Cuy::ModelForm` uses `form_with` under the hood and accepts all standard form options.

---

## Implementation Notes

### Field Rendering Strategy

Fields use a consistent wrapper pattern:

```html
<div class="sm:col-span-{span}">
  <label>...</label>
  <div class="mt-2">
    <input>
  </div>
  <p class="mt-3 text-sm/6"><!-- hint --></p>
  <p class="mt-2 text-sm/6 text-red-600"><!-- error --></p>
</div>
```

### Accessibility

All form components include:
- Proper `label` associations
- ARIA attributes for errors (`aria-invalid`, `aria-describedby`)
- Focus management
- Keyboard navigation
- Screen reader announcements

### Dark Mode

All components support dark mode out of the box using Tailwind's `dark:` variants.

---

## Future Enhancements

- [ ] Inline validation (Turbo-powered)
- [ ] Multi-step form wizard helper
- [ ] Conditional field rendering
- [ ] Field dependencies (show field B when field A = X)
- [ ] Auto-save drafts
- [ ] Form state persistence
- [ ] Combobox/autocomplete integration
- [ ] Date/time picker integration
- [ ] Rich text editor integration (Trix)

---

## Related Documentation

- [COMPONENTS.md](./COMPONENTS.md) - Individual component APIs
- [RAILS_INTEGRATION.md](./RAILS_INTEGRATION.md) - ActiveRecord introspection
- [README.md](./README.md) - General Cuy overview

