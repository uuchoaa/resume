# CUY - Cafofo User Ynterface

> A flexible, composable UI design system built with Phlex for Ruby on Rails applications.

**Cuy** (pronounced "kwee") is a design system that provides reusable UI components and layout primitives for building modern web applications. It's designed to be framework-agnostic in philosophy but optimized for Rails + Phlex with Tailwind CSS.

## 🎯 Philosophy

- **Generic & Reusable**: Components have no business logic and work with any data
- **Composable**: Build complex UIs from simple primitives using blocks/slots
- **Configurable**: Theme, layout strategies, and component defaults are all customizable
- **Zero JS Required**: Server-rendered components with optional progressive enhancement
- **Tailwind-First**: Built on Tailwind CSS utility classes for rapid customization

## 🏗️ Architecture

```
cuy/
├── lib/
│   ├── cuy/
│   │   ├── component.rb              # Base component (extends Phlex::HTML)
│   │   ├── config.rb                 # Main configuration
│   │   ├── theme_config.rb           # Colors, typography, spacing
│   │   ├── layout_config.rb          # Layout strategies (stacked, sidebar)
│   │   ├── components_config.rb      # Component defaults
│   │   ├── icons_config.rb           # Icon system
│   │   ├── components/
│   │   │   ├── layout/
│   │   │   │   ├── page.rb          # Main page orchestrator with DSL
│   │   │   │   ├── navbar.rb        # Top navigation shell
│   │   │   │   ├── sidebar.rb       # Sidebar navigation shell
│   │   │   │   ├── header.rb        # Page header
│   │   │   │   ├── section.rb       # Content section wrapper
│   │   │   │   └── container.rb     # Max-width container
│   │   │   ├── navigation/
│   │   │   │   ├── nav.rb           # Nav menu container
│   │   │   │   ├── nav_item.rb      # Nav items
│   │   │   │   ├── breadcrumb.rb    # Breadcrumb navigation
│   │   │   │   └── tabs.rb          # Tab navigation
│   │   │   ├── ui/
│   │   │   │   ├── button.rb        # Button with variants
│   │   │   │   ├── badge.rb         # Status badges
│   │   │   │   ├── avatar.rb        # Avatar/profile image
│   │   │   │   ├── card.rb          # Generic card container
│   │   │   │   ├── modal.rb         # Modal dialog
│   │   │   │   ├── toast.rb         # Notification toast
│   │   │   │   ├── dropdown.rb      # Dropdown menu
│   │   │   │   └── tooltip.rb       # Tooltips
│   │   │   ├── forms/
│   │   │   │   ├── form.rb          # Form wrapper
│   │   │   │   ├── field_group.rb   # Label + input wrapper
│   │   │   │   ├── input.rb         # Text input
│   │   │   │   ├── textarea.rb      # Textarea
│   │   │   │   ├── select.rb        # Select dropdown
│   │   │   │   ├── checkbox.rb      # Checkbox
│   │   │   │   └── radio.rb         # Radio button
│   │   │   ├── data/
│   │   │   │   ├── table.rb         # Data table
│   │   │   │   ├── description_list.rb  # Definition list
│   │   │   │   ├── timeline.rb      # Timeline/activity feed
│   │   │   │   └── empty_state.rb   # Empty state placeholder
│   │   │   └── feedback/
│   │   │       ├── alert.rb         # Alert messages
│   │   │       ├── spinner.rb       # Loading spinner
│   │   │       └── skeleton.rb      # Skeleton loaders
│   │   └── helpers/
│   │       └── layout_helpers.rb    # Helper methods for common patterns
│   └── cuy.rb                       # Main entry point
├── phlexbook/                       # Component documentation & preview
│   ├── stories/                     # Component examples
│   └── app.rb                       # Phlexbook Sinatra app
└── README.md
```

## 🚀 Quick Start

### Installation

```ruby
# Gemfile
gem 'cuy', path: '../cuy'  # or gem 'cuy', git: 'https://github.com/yourorg/cuy'
```

### Configuration

```ruby
# config/initializers/cuy.rb
Cuy.configure do |config|
  # Theme
  config.theme.primary_color = 'indigo'
  config.theme.secondary_color = 'gray'
  
  # Layout Strategy
  config.layout.strategy = :stacked  # or :sidebar
  
  # Component Defaults
  config.components.button[:default_variant] = :primary
  config.components.card[:default_shadow] = :md
end
```

### Basic Usage

```ruby
# app/views/posts/show.rb
class Views::Posts::Show < Views::Base
  def view_template
    page = Cuy::Components::Page.new
    
    page
      .navbar { render AppNavbar.new }
      .header { render PostHeader.new(@post) }
      .main do
        render Cuy::Card.new(title: "Post Content") do
          render PostContent.new(@post)
        end
        
        render Cuy::Card.new(title: "Comments") do
          render CommentsList.new(@comments)
        end
      end
    
    render page
  end
end
```

## 📐 Layout Strategies

Cuy supports multiple layout patterns inspired by [Tailwind UI](https://tailwindcss.com/plus/ui-blocks/application-ui/application-shells):

### 1. Stacked Layout

Navigation at the top, content below. Variants:
- **Default**: Standard white navbar with shadow
- **Branded**: Colored navbar (uses primary color)
- **Overlap**: Header overlaps content with card on top
- **Two-Row**: Navigation + secondary nav/breadcrumbs

```ruby
Cuy.configure do |config|
  config.layout.strategy = :stacked
  config.layout.stacked.variant = :overlap
  config.layout.stacked.navbar_style = :branded
  config.layout.stacked.background = :subtle  # :white, :subtle, :gray
end
```

### 2. Sidebar Layout

Vertical navigation on the side. Variants:
- **Simple**: Basic white sidebar
- **Dark**: Dark background sidebar
- **With Header**: Top header + sidebar
- **Branded**: Uses brand colors

```ruby
Cuy.configure do |config|
  config.layout.strategy = :sidebar
  config.layout.sidebar.variant = :simple
  config.layout.sidebar.dark = true
  config.layout.sidebar.width = '64'  # Tailwind width classes
  config.layout.sidebar.collapsible = true
end
```

### 3. Per-View Override

```ruby
# Use different layout for specific views
def view_template
  # This view uses sidebar even if global config is stacked
  page = Cuy::Components::Page.new(layout: :sidebar)
  
  page
    .sidebar { render SettingsSidebar.new }
    .main { render SettingsForm.new }
  
  render page
end
```

## 🎨 Component Library

### Layout Components

#### Page (Main Orchestrator)

```ruby
page = Cuy::Components::Page.new(layout: :stacked)

page
  .navbar { render Navbar.new }      # Top navigation
  .header { render PageHeader.new }  # Page header
  .aside { render Sidebar.new }      # Right sidebar (optional)
  .main do                           # Main content
    render MainContent.new
  end

render page
```

#### Card

```ruby
card = Cuy::Card.new(
  title: "Card Title",
  subtitle: "Optional subtitle"
)

card.footer { link_to "View All", "#" }

render card do
  # Card body content
  p { "Your content here" }
end
```

#### Container

```ruby
render Cuy::Container.new(size: :lg) do
  # Content constrained to max-width
end
```

### UI Components

#### Button

```ruby
render Cuy::Button.new(
  variant: :primary,  # :primary, :secondary, :outline, :ghost, :danger
  size: :md,          # :sm, :md, :lg, :xl
  href: "/posts"      # Optional link
) { "Click Me" }
```

#### Badge

```ruby
render Cuy::Badge.new(
  variant: :success,  # :primary, :success, :warning, :error, :neutral
  size: :md
) { "Active" }
```

#### Avatar

```ruby
render Cuy::Avatar.new(
  src: user.avatar_url,
  alt: user.name,
  size: :lg  # :xs, :sm, :md, :lg, :xl
)
```

### Navigation Components

#### Nav

```ruby
render Cuy::Nav.new(current_path: request.path, theme: :dark) do |nav|
  # Logo
  nav.logo do
    img(src: "/logo.svg", alt: "Company", class: "h-8 w-auto")
  end
  
  # Navigation items - auto-detects active state
  nav.item("/") { "Dashboard" }
  nav.item("/team") { "Team" }
  nav.item("/projects") { "Projects" }
  
  # Notifications with badge
  nav.notifications_icon(count: 3)
  
  # User profile dropdown
  nav.user_profile(
    avatar_url: current_user.avatar_url,
    name: current_user.name
  ) do |profile|
    profile.item("/profile") { "Your Profile" }
    profile.item("/settings") { "Settings" }
    profile.divider
    profile.item("/logout", method: :delete) { "Sign Out" }
  end
end
```

See [Components Guide](./COMPONENTS.md) for detailed documentation.

#### Breadcrumb

```ruby
render Cuy::Breadcrumb.new([
  { label: "Home", href: "/" },
  { label: "Posts", href: "/posts" },
  { label: "Show", current: true }
])
```

### Data Display

#### Description List

```ruby
render Cuy::DescriptionList.new do |dl|
  dl.item(label: "Email", value: user.email)
  dl.item(label: "Phone", value: user.phone)
  dl.item(label: "Bio", value: user.bio, span: 2)
end
```

#### Timeline

```ruby
events = [
  { icon: user_icon, color: 'bg-gray-400', description: 'Applied', date: '2024-01-01' },
  { icon: check_icon, color: 'bg-green-500', description: 'Approved', date: '2024-01-02' }
]

render Cuy::Timeline.new(events: events)
```

### Form Components

Cuy provides **three layers of form abstractions** for different use cases. See [Form Layouts Guide](./FORM_LAYOUTS.md) for comprehensive documentation.

#### Layer 1: Smart Form Builder (ModelForm)

For standard CRUD forms with maximum productivity:

```ruby
render Cuy::ModelForm.new(@user) do |f|
  f.section("Profile", "Public information") do
    f.input(:username, addon: "myapp.com/")
    f.textarea(:bio, hint: "Tell us about yourself")
    f.file_field(:avatar, preview: :avatar)
  end
  
  f.section("Account") do
    f.row do |r|
      r.input(:first_name, span: 3)
      r.input(:last_name, span: 3)
    end
    f.input(:email, type: :email, span: :full)
  end
  
  f.actions do |a|
    a.cancel
    a.submit("Save Profile")
  end
end
```

#### Layer 2: Manual Layout Control

For custom layouts with explicit control:

```ruby
render Cuy::Form.new(action: create_post_path) do
  render Cuy::Form::Section.new(title: "Post Details") do
    render Cuy::Form::Grid.new(cols: { sm: 6 }) do |grid|
      grid.column(span: :full) do
        render Cuy::Input.new(name: "title", label: "Title")
      end
      
      grid.column(span: 4) do
        render Cuy::Select.new(name: "category", label: "Category")
      end
      
      grid.column(span: 2) do
        render Cuy::Input.new(name: "publish_date", type: :date)
      end
    end
  end
  
  render Cuy::Form::Actions.new(align: :end) do |actions|
    actions.button("Cancel", variant: :outline)
    actions.submit("Publish")
  end
end
```

#### Layer 3: Full Phlex Control

Mix Cuy components with raw HTML for complete flexibility:

```ruby
form(action: create_post_path, method: :post) do
  div(class: "space-y-12") do
    # Custom layout
    div(class: "grid grid-cols-2 gap-4") do
      div { render Cuy::Input.new(name: "title") }
      div { render Cuy::Select.new(name: "status") }
    end
  end
  
  render Cuy::Form::Actions.new(align: :end)
end
```

## ⚙️ Configuration Reference

### Theme Configuration

```ruby
config.theme.primary_color = 'indigo'      # Tailwind color name
config.theme.secondary_color = 'gray'
config.theme.success_color = 'green'
config.theme.warning_color = 'yellow'
config.theme.error_color = 'red'
config.theme.info_color = 'blue'

# Typography
config.theme.font_family[:sans] = 'Inter, system-ui, sans-serif'
config.theme.font_sizes[:base] = 'text-base'

# Spacing
config.theme.spacing_scale[:md] = '6'  # 1.5rem

# Border Radius
config.theme.border_radius[:default] = 'rounded-lg'

# Shadows
config.theme.shadows[:default] = 'shadow-md'
```

### Component Defaults

```ruby
# Buttons
config.components.button[:default_variant] = :primary
config.components.button[:default_size] = :md

# Cards
config.components.card[:default_shadow] = :default
config.components.card[:default_padding] = :md

# Toasts
config.components.toast[:position] = :top_right
config.components.toast[:duration] = 5000  # milliseconds

# Tables
config.components.table[:striped] = false
config.components.table[:hoverable] = true
```

### Layout Configuration

```ruby
# Stacked Layout
config.layout.stacked.variant = :default  # :default, :overlap, :branded
config.layout.stacked.navbar_style = :default
config.layout.stacked.header_style = :default
config.layout.stacked.background = :white

# Sidebar Layout
config.layout.sidebar.variant = :simple
config.layout.sidebar.position = :left  # :left, :right
config.layout.sidebar.width = '64'
config.layout.sidebar.dark = false
config.layout.sidebar.collapsible = true
```

## 🎭 Phlexbook

**Phlexbook** is a Storybook-like component browser for Phlex components. It provides:

- **Live Component Previews**: See components in different states
- **Interactive Controls**: Adjust props/variants in real-time
- **Code Examples**: View generated HTML and Ruby code
- **Documentation**: Inline docs for each component
- **Responsive Preview**: Test components at different breakpoints

### Running Phlexbook

```bash
cd cuy/phlexbook
bundle install
ruby app.rb
```

Then open `http://localhost:4567` to browse components.

### Adding Stories

```ruby
# phlexbook/stories/button_story.rb
module Stories
  class ButtonStory < Phlexbook::Story
    component Cuy::Button
    
    story :default do
      render component.new { "Default Button" }
    end
    
    story :variants do
      [:primary, :secondary, :outline, :ghost, :danger].each do |variant|
        render component.new(variant: variant) { variant.to_s.titleize }
      end
    end
    
    story :sizes do
      [:sm, :md, :lg, :xl].each do |size|
        render component.new(size: size) { size.to_s.upcase }
      end
    end
  end
end
```

## 🔧 Development

### Setup

```bash
cd cuy
bundle install
```

### Testing Components

```bash
# Run component tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Building for Production

```bash
# Generate Tailwind config with all component classes
rake cuy:tailwind:generate

# This scans all components and extracts Tailwind classes
# to ensure they're included in production builds
```

### Component Development Guidelines

1. **No Business Logic**: Components should be pure presentation
2. **Accept Blocks**: Use blocks/slots for flexible composition
3. **Sensible Defaults**: Work out of the box with minimal config
4. **Tailwind Classes**: Use utility classes, avoid custom CSS
5. **Accessibility**: Include ARIA attributes and semantic HTML
6. **Responsive**: Mobile-first responsive design

### Example Component Structure

```ruby
module Cuy
  module Components
    class YourComponent < Cuy::Component
      def initialize(variant: :default, **attrs)
        @variant = variant
        @attrs = attrs
      end

      def view_template(&block)
        div(class: component_classes, **@attrs) do
          # Component markup
          yield if block_given?
        end
      end

      private

      def component_classes
        base = "your-base-classes"
        variant_class = variant_classes[@variant]
        
        [base, variant_class].join(' ')
      end

      def variant_classes
        {
          default: "bg-white text-gray-900",
          primary: "bg-#{Cuy.config.theme.primary_color}-600 text-white"
        }
      end
    end
  end
end
```

## 📚 Usage in Apps

### App Structure

```
app/
├── components/              # App-specific components
│   ├── base.rb             # App::Component < Cuy::Component
│   ├── posts/
│   │   ├── card.rb         # Uses Cuy::Card
│   │   ├── list.rb         # Uses Cuy::Table
│   │   └── header.rb       # Uses Cuy::PageHeader
│   └── shared/
│       ├── app_navbar.rb   # Uses Cuy::Navbar
│       └── footer.rb       # Custom footer
└── views/
    ├── base.rb             # Views::Base (layout wrapper)
    └── posts/
        ├── index.rb        # Composes Cuy + App components
        └── show.rb
```

### Separation of Concerns

**Cuy (Generic)**:
- `Cuy::Card` - Generic card container
- `Cuy::Button` - Generic button with variants
- `Cuy::Table` - Generic data table
- `Cuy::Timeline` - Generic event list

**App (Business-Specific)**:
- `PostCard` - Uses `Cuy::Card` + post-specific logic
- `PostTable` - Uses `Cuy::Table` + post columns
- `PostTimeline` - Uses `Cuy::Timeline` + post events
- `AppNavbar` - Uses `Cuy::Navbar` + app routes

## 🎯 Design Decisions

### Why Phlex?

- **Ruby DSL**: Write HTML in Ruby with full language power
- **Type Safety**: Better than ERB strings
- **Performance**: Faster than ERB/HAML
- **Composability**: Components are just Ruby classes
- **No Magic**: Clear, explicit component composition

### Why Tailwind?

- **Utility-First**: Rapid prototyping and iteration
- **Consistent Design**: Design tokens baked in
- **Responsive**: Mobile-first responsive utilities
- **Production-Ready**: PurgeCSS removes unused styles
- **Community**: Large ecosystem and patterns

### Why No JavaScript?

- **Server-First**: Keep logic on the server
- **Progressive Enhancement**: Add JS only when needed
- **Simplicity**: Easier to maintain and debug
- **Performance**: Less JS = faster initial load
- **Optional**: Add Hotwire/Turbo for interactivity

## 🧠 Rails Integration

Cuy includes powerful **Model-Aware Components** that leverage Rails' introspection to automatically generate forms, tables, and detail views. See [Rails Integration Guide](./RAILS_INTEGRATION.md) for details.

Quick preview:

```ruby
# Auto-generated form - detects fields, types, validations, associations
render Cuy::ModelForm.new(model: @post)

# Auto-generated table - formats columns, adds actions
render Cuy::ModelTable.new(collection: @posts)

# Auto-generated detail view - shows all attributes beautifully
render Cuy::ModelDetails.new(model: @post)
```

**Benefits:**
- 95% less code to maintain
- Zero configuration for standard cases
- Automatic I18n support
- Type-safe by default
- Adapts when models change

## 🚧 Roadmap

- [ ] Complete all base components
- [ ] Phlexbook implementation
- [ ] Model-aware components (ModelForm, ModelTable, ModelDetails)
- [ ] Dark mode support
- [ ] Animation/transition system
- [ ] Form validation helpers
- [ ] Accessibility audit
- [ ] RTL language support
- [ ] Component variants generator
- [ ] Tailwind plugin
- [ ] Rails generators (`rails g cuy:scaffold`)

## 📖 Resources

- [Phlex Documentation](https://www.phlex.fun/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Tailwind UI](https://tailwindcss.com/plus)
- [Components Guide](./COMPONENTS.md) - Detailed component documentation
- [Form Layouts Guide](./FORM_LAYOUTS.md) - Form layout strategies and patterns
- [Rails Integration Guide](./RAILS_INTEGRATION.md) - Model-aware components
- [Migration Guide](./MIGRATION_GUIDE.md) - How to migrate Tailwind UI HTML to Cuy
- [Component Examples](./phlexbook/stories/)

## 🤝 Contributing

1. Follow component development guidelines
2. Add Phlexbook story for new components
3. Include tests for behavior
4. Update documentation
5. Keep components generic and reusable

## 📝 Development Notes

### Key Insights from Design Process

1. **Page DSL Pattern**: The fluent/chainable page builder (`.navbar { }.main { }`) provides excellent DX
2. **Layout Strategies**: Supporting both stacked and sidebar layouts covers 90% of app needs
3. **Configuration Over Code**: Theme and component defaults should be configurable without code changes
4. **Blocks for Flexibility**: Using blocks/slots allows apps to customize without component inheritance
5. **Tailwind Dependency**: Cuy is intentionally Tailwind-dependent; don't try to abstract it away

### Common Patterns

```ruby
# Pattern 1: Card with header and footer
card = Cuy::Card.new(title: "Title")
card.footer { link_to "View All", "#" }
render card { # body content }

# Pattern 2: Page with sidebar layout
page = Cuy::Components::Page.new(layout: :sidebar)
page.sidebar { nav }.main { content }

# Pattern 3: Description list for key-value data
render Cuy::DescriptionList.new do |dl|
  model.attributes.each { |k, v| dl.item(label: k, value: v) }
end
```

### Migration from HTML/ERB

When migrating existing HTML (like `welcome.html`):
1. Identify reusable patterns → Create Cuy components
2. Identify app-specific logic → Create app components that use Cuy
3. Use Page DSL to compose layouts
4. Extract inline styles to Tailwind classes
5. Replace hardcoded values with configuration

---

**Built with ❤️ for the Ruby community**
