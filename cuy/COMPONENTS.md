# Cuy Components Guide

Detailed documentation for all Cuy base components.

## Navigation Components

### Nav - Application Navigation Bar

A fully-featured navigation component with desktop/mobile support, notifications, and user profile.

#### Basic Usage

```ruby
render Cuy::Nav.new(current_path: request.path) do |nav|
  # Logo/Brand
  nav.logo do
    img(src: "/logo.svg", alt: "Company", class: "h-8 w-auto")
  end
  
  # Navigation Items
  nav.item("/") { "Dashboard" }
  nav.item("/team") { "Team" }
  nav.item("/projects") { "Projects" }
  nav.item("/calendar") { "Calendar" }
  
  # User Profile Dropdown
  nav.user_profile(
    avatar_url: current_user.avatar_url,
    name: current_user.name
  ) do |profile|
    profile.item("/profile") { "Your Profile" }
    profile.item("/settings") { "Settings" }
    profile.item("/logout", method: :delete) { "Sign Out" }
  end
  
  # Notifications
  nav.notifications_icon(count: 3) do
    # Optional: custom notification panel
  end
end
```

#### Complete Example

```ruby
# app/components/app_navbar.rb
class Components::AppNavbar < Cuy::Component
  def initialize(current_user:, current_path:, notifications_count: 0)
    @current_user = current_user
    @current_path = current_path
    @notifications_count = notifications_count
  end

  def view_template
    render Cuy::Nav.new(
      current_path: @current_path,
      theme: :dark  # :light or :dark
    ) do |nav|
      # Logo
      nav.logo do
        a(href: root_path) do
          img(
            src: asset_path("logo.svg"),
            alt: "Company Name",
            class: "h-8 w-auto"
          )
        end
      end
      
      # Main Navigation
      nav.item(dashboard_path) { "Dashboard" }
      nav.item(deals_path) { "Deals" }
      nav.item(agencies_path) { "Agencies" }
      nav.item(reports_path) { "Reports" }
      
      # Notifications
      nav.notifications_icon(count: @notifications_count) do |notifications|
        notifications.item(
          title: "New message from John",
          time: "5 minutes ago",
          href: message_path(123)
        )
        notifications.item(
          title: "Deal moved to closed",
          time: "1 hour ago",
          href: deal_path(456)
        )
        notifications.footer do
          a(href: notifications_path) { "View all notifications" }
        end
      end
      
      # User Profile
      nav.user_profile(
        avatar_url: @current_user.avatar_url,
        name: @current_user.name,
        email: @current_user.email
      ) do |profile|
        profile.item(profile_path) do
          div do
            div(class: "text-sm font-medium") { "Your Profile" }
            div(class: "text-xs text-gray-500") { "View and edit" }
          end
        end
        
        profile.divider
        
        profile.item(settings_path) { "Settings" }
        profile.item(billing_path) { "Billing" }
        
        profile.divider
        
        profile.item(
          logout_path,
          method: :delete,
          data: { turbo_method: :delete }
        ) { "Sign Out" }
      end
    end
  end
end
```

#### API Reference

##### `Nav.new(options)`

**Options:**
- `current_path:` (String) - Current page path for active state detection
- `theme:` (Symbol) - `:light` or `:dark` (default: `:light`)
- `layout:` (Symbol) - `:centered` or `:split` (default: `:centered`)
- `border_style:` (Symbol) - `:rounded` or `:bottom` (default: `:rounded`)
- `sticky:` (Boolean) - Make nav sticky on scroll (default: `false`)
- `transparent:` (Boolean) - Transparent background (default: `false`)

##### `nav.logo(&block)`

Renders the logo/brand area.

```ruby
nav.logo do
  a(href: root_path, class: "flex items-center") do
    img(src: "/logo.svg", class: "h-8 w-auto")
    span(class: "ml-2 text-xl font-bold") { "Brand" }
  end
end
```

##### `nav.item(path, **options, &block)`

Renders a navigation link. Auto-detects active state from `current_path`.

**Parameters:**
- `path` (String) - URL path
- `**options` - Additional HTML attributes

```ruby
# Basic
nav.item("/dashboard") { "Dashboard" }

# With icon
nav.item("/settings") do
  svg_icon(:cog, class: "w-5 h-5 mr-2")
  span { "Settings" }
end

# With badge
nav.item("/messages") do
  span { "Messages" }
  render Cuy::Badge.new(variant: :primary) { "3" }
end
```

**Active State Classes:**
- Active: `bg-gray-900 text-white` (dark theme)
- Inactive: `text-gray-300 hover:bg-white/5 hover:text-white`

##### `nav.user_profile(avatar_url:, name:, email: nil, mobile_profile: false, &block)`

Renders user profile dropdown.

**Parameters:**
- `avatar_url:` (String) - User avatar image URL
- `name:` (String) - User display name
- `email:` (String, optional) - User email
- `mobile_profile:` (Boolean) - Show profile info in mobile menu (default: `false`)

```ruby
nav.user_profile(
  avatar_url: user.avatar_url,
  name: user.name,
  email: user.email
) do |profile|
  # Profile menu items
  profile.item("/profile") { "Your Profile" }
  profile.item("/settings") { "Settings" }
  
  # Divider
  profile.divider
  
  # Sign out
  profile.item("/logout", method: :delete) { "Sign Out" }
end
```

**Profile Menu Methods:**
- `profile.item(path, **options, &block)` - Menu item
- `profile.divider` - Visual separator
- `profile.header(&block)` - Custom header content

##### `nav.search(placeholder: "Search", name: "search", **options)`

Renders an integrated search bar in the navigation.

**Parameters:**
- `placeholder:` (String) - Search placeholder text (default: `"Search"`)
- `name:` (String) - Form input name (default: `"search"`)
- `**options` - Additional HTML attributes

```ruby
# Basic
nav.search

# Custom placeholder
nav.search(placeholder: "Search projects...")

# With custom name and attributes
nav.search(
  name: "q",
  placeholder: "Search anything",
  class: "custom-search"
)

# With form action
nav.search(
  placeholder: "Search",
  form_action: search_path,
  form_method: :get
)
```

**Features:**
- ✅ Integrated magnifying glass icon
- ✅ Responsive width (full on mobile, constrained on desktop)
- ✅ Auto-focuses on `/` key press (optional)
- ✅ Dark mode support

##### `nav.primary_action(href:, **options, &block)`

Renders a prominent primary action button (e.g., "New Job", "Create Post").

**Parameters:**
- `href:` (String) - Action URL
- `variant:` (Symbol) - Button variant (default: `:primary`)
- `**options` - Additional HTML attributes

```ruby
# Basic
nav.primary_action(href: new_job_path) { "New Job" }

# With icon
nav.primary_action(href: new_post_path) do
  svg_icon(:plus, class: "size-5 -ml-0.5")
  span { "New Post" }
end

# Custom variant
nav.primary_action(
  href: new_deal_path,
  variant: :success,
  class: "font-bold"
) { "Create Deal" }
```

**Styling:**
```ruby
# Default (primary variant)
"inline-flex items-center gap-x-1.5 rounded-md bg-indigo-500 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400"
```

##### `nav.notifications_icon(count: 0, &block)`

Renders notifications bell icon with optional badge count.

**Basic (Icon Only):**
```ruby
nav.notifications_icon(count: 5)
```

**With Notification Panel:**
```ruby
nav.notifications_icon(count: 3) do |notifications|
  notifications.item(
    title: "New message",
    description: "From John Doe",
    time: "5 min ago",
    href: "/messages/123",
    unread: true
  )
  
  notifications.item(
    title: "Deal updated",
    description: "Status changed to closed",
    time: "1 hour ago",
    href: "/deals/456"
  )
  
  notifications.empty do
    p(class: "text-center text-gray-500") { "No notifications" }
  end
  
  notifications.footer do
    a(href: "/notifications", class: "block text-center") do
      "View all notifications"
    end
  end
end
```

**Notification Item Properties:**
- `title:` (String) - Notification title
- `description:` (String, optional) - Additional details
- `time:` (String) - Time ago or timestamp
- `href:` (String) - Link URL
- `unread:` (Boolean) - Show unread indicator
- `icon:` (String, optional) - Icon name or SVG

##### `nav.notifications_center(&block)`

Full-featured notification center panel (alternative to simple icon).

```ruby
nav.notifications_center do |center|
  center.tabs do |tabs|
    tabs.tab("all", active: true) { "All" }
    tabs.tab("unread") { "Unread" }
    tabs.tab("mentions") { "Mentions" }
  end
  
  center.list do |list|
    @notifications.each do |notification|
      list.item(
        title: notification.title,
        description: notification.body,
        time: time_ago_in_words(notification.created_at),
        href: notification.url,
        unread: !notification.read?,
        avatar_url: notification.sender.avatar_url
      )
    end
  end
  
  center.footer do
    a(href: notifications_path) { "View all" }
  end
end
```

#### Mobile Menu

Mobile menu is automatically generated from desktop navigation items.

**Basic Mobile Menu:**
- Navigation items are automatically included
- User profile items appear at bottom

**With User Profile Info (Split Layout):**

When `mobile_profile: true` is set on `user_profile`, the mobile menu includes:
- User avatar, name, and email at the top
- Navigation items
- Notification bell
- Profile menu items (Your Profile, Settings, Sign Out)

```ruby
nav.user_profile(
  avatar_url: user.avatar_url,
  name: user.name,
  email: user.email,
  mobile_profile: true  # Shows profile card in mobile menu
)
```

**Mobile Menu Structure (with profile):**
```
┌────────────────────────────┐
│ Nav Items                  │
│ - Dashboard                │
│ - Team                     │
│ - Projects                 │
├────────────────────────────┤
│ [👤] Tom Cook       [🔔]  │
│      tom@example.com       │
├────────────────────────────┤
│ Your Profile               │
│ Settings                   │
│ Sign Out                   │
└────────────────────────────┘
```

**Customize Mobile Menu:**
```ruby
nav.mobile_menu do |mobile|
  # Override mobile-specific behavior if needed
  mobile.show_profile_card = true
  mobile.show_notifications = true
end
```

#### Layout Variants

##### Variant 1: Centered Layout (Default)

Logo on left, nav items centered, actions on right.

```ruby
render Cuy::Nav.new(current_path: @current_path, layout: :centered) do |nav|
  nav.logo { img(src: "/logo.svg", class: "h-8 w-auto") }
  nav.item("/") { "Dashboard" }
  nav.item("/team") { "Team" }
  nav.notifications_icon(count: 3)
  nav.user_profile(avatar_url: user.avatar_url, name: user.name)
end
```

##### Variant 2: Split Layout with Primary Action

Logo and nav on left, action button and profile on right.

```ruby
render Cuy::Nav.new(
  current_path: @current_path,
  layout: :split,  # or justify: :between
  theme: :dark
) do |nav|
  # Left side: Logo + Nav
  nav.logo { img(src: "/logo.svg", class: "h-8 w-auto") }
  nav.item("/") { "Dashboard" }
  nav.item("/team") { "Team" }
  nav.item("/projects") { "Projects" }
  
  # Right side: Primary Action + Notifications + Profile
  nav.primary_action(href: new_job_path) do
    svg_icon(:plus, class: "size-5 -ml-0.5")
    span { "New Job" }
  end
  
  nav.notifications_icon(count: 3)
  
  nav.user_profile(
    avatar_url: user.avatar_url,
    name: user.name,
    email: user.email,
    mobile_profile: true  # Show profile in mobile menu
  )
end
```

**Split Layout Structure:**
```
┌──────────────────────────────────────────────────┐
│ [Logo] [Nav Items...]     [Action] [Bell] [👤]  │
└──────────────────────────────────────────────────┘
```

##### Variant 3: With Search Bar

Light theme with integrated search bar.

```ruby
render Cuy::Nav.new(
  current_path: @current_path,
  theme: :light,
  border_style: :bottom  # bottom border on items instead of rounded
) do |nav|
  # Logo
  nav.logo { img(src: "/logo.svg", class: "h-8 w-auto") }
  
  # Navigation items with bottom border
  nav.item("/") { "Dashboard" }
  nav.item("/team") { "Team" }
  nav.item("/projects") { "Projects" }
  nav.item("/calendar") { "Calendar" }
  
  # Search bar
  nav.search(
    placeholder: "Search",
    name: "search"
  )
  
  # Notifications + Profile
  nav.notifications_icon
  nav.user_profile(
    avatar_url: user.avatar_url,
    name: user.name,
    email: user.email,
    mobile_profile: true
  )
end
```

**Search Bar Layout:**
```
┌────────────────────────────────────────────────────────┐
│ [Logo] [Nav Items]    [Search Bar]    [Bell] [👤]     │
└────────────────────────────────────────────────────────┘
```

#### Theming

**Dark Theme (default for nav):**
```ruby
render Cuy::Nav.new(theme: :dark) do |nav|
  # Dark background with light text
end
```

**Light Theme:**
```ruby
render Cuy::Nav.new(theme: :light) do |nav|
  # Light background with dark text
end
```

**Custom Styling:**
```ruby
render Cuy::Nav.new(
  theme: :dark,
  class: "border-b border-gray-700"
) do |nav|
  # Additional classes applied to nav element
end
```

#### Implementation Details

```ruby
# cuy/lib/cuy/components/nav.rb
module Cuy
  module Components
    class Nav < Cuy::Component
      def initialize(current_path:, theme: :dark, sticky: false, transparent: false, **attrs)
        @current_path = current_path
        @theme = theme
        @sticky = sticky
        @transparent = transparent
        @attrs = attrs
        @items = []
        @logo_block = nil
        @user_profile_block = nil
        @notifications_block = nil
      end

      def view_template(&block)
        nav(class: nav_classes, **@attrs) do
          div(class: "mx-auto max-w-7xl px-2 sm:px-6 lg:px-8") do
            div(class: "relative flex h-16 items-center justify-between") do
              render_mobile_toggle
              render_main_content
              render_actions
            end
          end
          render_mobile_menu
        end
      end

      # DSL Methods
      def logo(&block)
        @logo_block = block
      end

      def item(path, **options, &block)
        @items << { path: path, options: options, block: block }
      end

      def user_profile(avatar_url:, name:, email: nil, &block)
        @user_profile_block = {
          avatar_url: avatar_url,
          name: name,
          email: email,
          block: block
        }
      end

      def notifications_icon(count: 0, &block)
        @notifications_block = {
          type: :icon,
          count: count,
          block: block
        }
      end

      def notifications_center(&block)
        @notifications_block = {
          type: :center,
          block: block
        }
      end

      private

      def nav_classes
        base = "relative"
        base += " sticky top-0 z-50" if @sticky
        
        background = case @theme
        when :dark
          @transparent ? "bg-gray-800/80 backdrop-blur" : "bg-gray-800"
        when :light
          @transparent ? "bg-white/80 backdrop-blur" : "bg-white shadow"
        end
        
        [base, background].join(" ")
      end

      def render_mobile_toggle
        div(class: "absolute inset-y-0 left-0 flex items-center sm:hidden") do
          button(
            type: "button",
            class: "relative inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-white/5 hover:text-white focus:outline-2 focus:outline-offset-1 focus:outline-indigo-500"
          ) do
            span(class: "sr-only") { "Open main menu" }
            # Hamburger icon
            render_icon(:menu)
          end
        end
      end

      def render_main_content
        div(class: "flex flex-1 items-center justify-center sm:items-stretch sm:justify-start") do
          div(class: "flex shrink-0 items-center") do
            @logo_block&.call
          end
          
          render_desktop_nav
        end
      end

      def render_desktop_nav
        div(class: "hidden sm:ml-6 sm:block") do
          div(class: "flex space-x-4") do
            @items.each do |item|
              render_nav_item(item)
            end
          end
        end
      end

      def render_nav_item(item)
        active = @current_path.start_with?(item[:path])
        
        classes = if active
          "rounded-md bg-gray-900 px-3 py-2 text-sm font-medium text-white"
        else
          "rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:bg-white/5 hover:text-white"
        end
        
        a(
          href: item[:path],
          class: classes,
          aria_current: (active ? "page" : nil),
          **item[:options]
        ) do
          item[:block].call
        end
      end

      def render_actions
        div(class: "absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0") do
          render_notifications if @notifications_block
          render_user_profile if @user_profile_block
        end
      end

      def render_notifications
        if @notifications_block[:type] == :icon
          render_notification_icon
        else
          render_notification_center
        end
      end

      def render_notification_icon
        button(
          type: "button",
          class: "relative rounded-full p-1 text-gray-400 hover:text-white focus:outline-2 focus:outline-offset-2 focus:outline-indigo-500"
        ) do
          span(class: "sr-only") { "View notifications" }
          
          # Bell icon
          svg(
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            stroke_width: "1.5",
            class: "size-6"
          ) do |s|
            s.path(
              d: "M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0",
              stroke_linecap: "round",
              stroke_linejoin: "round"
            )
          end
          
          # Badge count
          if @notifications_block[:count] > 0
            span(
              class: "absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs text-white"
            ) do
              @notifications_block[:count].to_s
            end
          end
        end
      end

      def render_user_profile
        data = @user_profile_block
        
        div(class: "relative ml-3") do
          button(
            type: "button",
            class: "relative flex rounded-full focus:outline-2 focus:outline-offset-2 focus:outline-indigo-500"
          ) do
            span(class: "sr-only") { "Open user menu" }
            img(
              src: data[:avatar_url],
              alt: data[:name],
              class: "size-8 rounded-full bg-gray-800 outline outline-1 -outline-offset-1 outline-white/10"
            )
          end
          
          # Dropdown menu (requires JS or Hotwire for interaction)
          div(
            class: "hidden absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black/5",
            role: "menu"
          ) do
            data[:block]&.call(ProfileMenu.new(self))
          end
        end
      end

      def render_mobile_menu
        div(class: "hidden sm:hidden", id: "mobile-menu") do
          div(class: "space-y-1 px-2 pb-3 pt-2") do
            @items.each do |item|
              render_mobile_nav_item(item)
            end
          end
        end
      end

      def render_mobile_nav_item(item)
        active = @current_path.start_with?(item[:path])
        
        classes = if active
          "block rounded-md bg-gray-900 px-3 py-2 text-base font-medium text-white"
        else
          "block rounded-md px-3 py-2 text-base font-medium text-gray-300 hover:bg-white/5 hover:text-white"
        end
        
        a(
          href: item[:path],
          class: classes,
          aria_current: (active ? "page" : nil)
        ) do
          item[:block].call
        end
      end

      # Helper class for profile menu DSL
      class ProfileMenu
        def initialize(nav)
          @nav = nav
        end

        def item(path, **options, &block)
          a(
            href: path,
            class: "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100",
            role: "menuitem",
            **options,
            &block
          )
        end

        def divider
          div(class: "border-t border-gray-100 my-1")
        end

        def header(&block)
          div(class: "px-4 py-2 text-xs text-gray-500 uppercase tracking-wider", &block)
        end
      end
    end
  end
end
```

#### Complete Working Examples

##### Example 1: Centered Layout (Dashboard)

```ruby
# app/components/shared/application_nav.rb
module Components
  module Shared
    class ApplicationNav < Cuy::Component
      def initialize(current_user:, current_path:)
        @current_user = current_user
        @current_path = current_path
      end

      def view_template
        render Cuy::Nav.new(
          current_path: @current_path,
          theme: :dark,
          sticky: true
        ) do |nav|
          # Logo
          nav.logo do
            a(href: root_path, class: "flex items-center space-x-2") do
              img(src: asset_path("logo.svg"), class: "h-8 w-auto")
              span(class: "text-white font-semibold text-lg") { "MyApp" }
            end
          end
          
          # Main Navigation
          nav.item(dashboard_path) { "Dashboard" }
          nav.item(deals_path) { "Deals" }
          nav.item(agencies_path) { "Agencies" }
          nav.item(reports_path) { "Reports" }
          
          # Notifications
          nav.notifications_icon(count: unread_notifications_count) do |n|
            recent_notifications.each do |notification|
              n.item(
                title: notification.title,
                time: time_ago_in_words(notification.created_at),
                href: notification_path(notification),
                unread: !notification.read?
              )
            end
            
            n.footer do
              a(href: notifications_path, class: "block text-center py-2 text-sm hover:bg-gray-50") do
                "View all notifications"
              end
            end
          end
          
          # User Profile
          nav.user_profile(
            avatar_url: @current_user.avatar_url,
            name: @current_user.name,
            email: @current_user.email
          ) do |profile|
            profile.item(profile_path) { "Your Profile" }
            profile.item(settings_path) { "Settings" }
            profile.divider
            profile.item(logout_path, data: { turbo_method: :delete }) { "Sign Out" }
          end
        end
      end

      private

      def unread_notifications_count
        @current_user.notifications.unread.count
      end

      def recent_notifications
        @current_user.notifications.recent.limit(5)
      end
    end
  end
end
```

##### Example 2: Split Layout with Primary Action

```ruby
# app/components/shared/jobs_nav.rb
module Components
  module Shared
    class JobsNav < Cuy::Component
      def initialize(current_user:, current_path:)
        @current_user = current_user
        @current_path = current_path
      end

      def view_template
        render Cuy::Nav.new(
          current_path: @current_path,
          layout: :split,
          theme: :dark,
          sticky: true
        ) do |nav|
          # Logo
          nav.logo do
            img(src: asset_path("logo.svg"), class: "h-8 w-auto")
          end
          
          # Navigation (left side, next to logo)
          nav.item(dashboard_path) { "Dashboard" }
          nav.item(team_path) { "Team" }
          nav.item(projects_path) { "Projects" }
          nav.item(calendar_path) { "Calendar" }
          
          # Primary Action (right side)
          nav.primary_action(href: new_job_path) do
            svg(viewBox: "0 0 20 20", fill: "currentColor", class: "size-5 -ml-0.5") do |s|
              s.path(d: "M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z")
            end
            span { "New Job" }
          end
          
          # Notifications
          nav.notifications_icon(count: unread_count)
          
          # User Profile (with mobile profile card)
          nav.user_profile(
            avatar_url: @current_user.avatar_url,
            name: @current_user.name,
            email: @current_user.email,
            mobile_profile: true  # Shows profile card in mobile menu
          ) do |profile|
            profile.item(profile_path) { "Your profile" }
            profile.item(settings_path) { "Settings" }
            profile.item(logout_path, data: { turbo_method: :delete }) { "Sign out" }
          end
        end
      end

      private

      def unread_count
        @current_user.notifications.unread.count
      end
    end
  end
end
```

##### Example 3: Light Theme with Search Bar

```ruby
# app/components/shared/search_nav.rb
module Components
  module Shared
    class SearchNav < Cuy::Component
      def initialize(current_user:, current_path:)
        @current_user = current_user
        @current_path = current_path
      end

      def view_template
        render Cuy::Nav.new(
          current_path: @current_path,
          theme: :light,
          border_style: :bottom,  # Bottom border on nav items
          sticky: true
        ) do |nav|
          # Logo (with light/dark variants)
          nav.logo do
            img(
              src: asset_path("logo-dark.svg"),
              alt: "Company",
              class: "h-8 w-auto dark:hidden"
            )
            img(
              src: asset_path("logo-light.svg"),
              alt: "Company",
              class: "hidden h-8 w-auto dark:block"
            )
          end
          
          # Navigation with bottom border style
          nav.item(dashboard_path) { "Dashboard" }
          nav.item(team_path) { "Team" }
          nav.item(projects_path) { "Projects" }
          nav.item(calendar_path) { "Calendar" }
          
          # Integrated search bar
          nav.search(
            placeholder: "Search",
            name: "search",
            form_action: search_path,
            form_method: :get
          )
          
          # Notifications
          nav.notifications_icon
          
          # User Profile
          nav.user_profile(
            avatar_url: @current_user.avatar_url,
            name: @current_user.name,
            email: @current_user.email,
            mobile_profile: true
          ) do |profile|
            profile.item(profile_path) { "Your profile" }
            profile.item(settings_path) { "Settings" }
            profile.item(logout_path, data: { turbo_method: :delete }) { "Sign out" }
          end
        end
      end
    end
  end
end
```

---

## Form Components

### Input - Form Input Field

Flexible input component with support for labels, help text, icons, add-ons, and various styles.

#### Basic Usage

```ruby
render Cuy::Input.new(
  name: "email",
  type: :email,
  label: "Email",
  placeholder: "you@example.com"
)
```

#### API Reference

##### `Cuy::Input.new(**options)`

**Required:**
- `name:` (String) - Input name attribute

**Optional:**
- `type:` (Symbol) - Input type (`:text`, `:email`, `:tel`, `:password`, `:search`, `:number`, `:date`, `:url`, etc.)
- `label:` (String) - Label text
- `hint:` (String) - Help text below the input
- `placeholder:` (String) - Placeholder text
- `error:` (String) - Error message (shows error state)
- `value:` (String) - Input value
- `disabled:` (Boolean) - Disabled state
- `icon:` (Symbol) - Leading icon (`:search`, `:user`, `:envelope`, `:phone`, `:briefcase`)
- `trailing_icon:` (Symbol) - Icon on the right side
- `addon:` (String) - Leading text add-on (e.g., "https://")
- `corner_hint:` (String) - Optional text in top-right corner
- `label_style:` (Symbol) - `:normal`, `:inset`, or `:floating`
- `group_position:` (Symbol) - For shared borders: `:top`, `:middle`, `:bottom`, `:bottom_left`, `:bottom_right`

#### Variants

##### With Help Text

```ruby
render Cuy::Input.new(
  name: "email",
  label: "Email",
  hint: "We'll never share your email with anyone else.",
  placeholder: "you@example.com"
)
```

##### With Validation Error

```ruby
render Cuy::Input.new(
  name: "email",
  label: "Email",
  value: "not-an-email",
  error: "Please provide a valid email address."
)
```

##### With Corner Hint

```ruby
render Cuy::Input.new(
  name: "username",
  label: "Username",
  corner_hint: "Optional",
  placeholder: "johndoe"
)
```

##### With Leading Icon

```ruby
render Cuy::Input.new(
  name: "search",
  type: :search,
  label: "Search candidates",
  icon: :search,
  placeholder: "John Smith"
)
```

##### With Trailing Icon

```ruby
render Cuy::Input.new(
  name: "website",
  type: :url,
  label: "Website URL",
  trailing_icon: :link,
  placeholder: "https://example.com"
)
```

##### With Leading Add-on

```ruby
render Cuy::Input.new(
  name: "website",
  label: "Website",
  addon: "https://",
  placeholder: "www.example.com"
)
```

##### With Trailing Add-on

```ruby
# Text add-on
render Cuy::Input.new(
  name: "weight",
  label: "Weight",
  trailing_addon: "kg"
)

# Button add-on (using block)
render Cuy::Input.new(
  name: "query",
  label: "Search candidates",
  icon: :search,
  placeholder: "John Smith"
) do |input|
  input.trailing_button do
    svg_icon(:filter, class: "size-4 -ml-0.5")
    span { "Sort" }
  end
end
```

##### With Inline Dropdown

```ruby
render Cuy::Input.new(
  name: "phone",
  type: :tel,
  label: "Phone number",
  placeholder: "123-456-7890"
) do |input|
  input.leading_select(
    name: "country",
    options: [
      { value: "us", label: "US" },
      { value: "ca", label: "CA" },
      { value: "eu", label: "EU" }
    ],
    selected: "us"
  )
end
```

##### Grouped Inputs (Shared Borders)

```ruby
fieldset do
  legend(class: "block text-sm/6 font-medium") { "Card details" }
  
  div(class: "mt-2 grid grid-cols-2") do
    # Card number (full width, top)
    div(class: "col-span-2") do
      render Cuy::Input.new(
        name: "card_number",
        placeholder: "Card number",
        group_position: :top
      )
    end
    
    # Expiration date (bottom-left)
    div(class: "-mt-px -mr-px") do
      render Cuy::Input.new(
        name: "expiration",
        placeholder: "MM / YY",
        group_position: :bottom_left
      )
    end
    
    # CVC (bottom-right)
    div(class: "-mt-px") do
      render Cuy::Input.new(
        name: "cvc",
        placeholder: "CVC",
        group_position: :bottom_right
      )
    end
  end
end
```

##### Inset Label (Floating Within Input)

```ruby
render Cuy::Input.new(
  name: "name",
  label: "Name",
  placeholder: "Jane Smith",
  label_style: :inset
)
```

**Result:**
```
┌─────────────────────────┐
│ Name                    │
│ Jane Smith              │
└─────────────────────────┘
```

##### Overlapping/Floating Label

```ruby
render Cuy::Input.new(
  name: "name",
  label: "Name",
  placeholder: "Jane Smith",
  label_style: :floating
)
```

**Result:**
```
   ┌─Name─┐
───┤      ├──────────────
   │ Jane Smith          │
   └─────────────────────┘
```

##### Disabled State

```ruby
render Cuy::Input.new(
  name: "email",
  label: "Email",
  value: "user@example.com",
  disabled: true
)
```

##### Hidden Label (Visually Hidden)

```ruby
render Cuy::Input.new(
  name: "search",
  label: "Search",
  hide_label: true,
  placeholder: "Search..."
)
```

#### Complete Example: Search Input with Sort Button

```ruby
class Components::SearchBar < Cuy::Component
  def view_template
    render Cuy::Input.new(
      name: "q",
      type: :search,
      label: "Search candidates",
      icon: :search,
      placeholder: "John Smith"
    ) do |input|
      input.trailing_button(
        type: "button",
        class: "gap-x-1.5"
      ) do
        svg(viewBox: "0 0 16 16", fill: "currentColor", class: "size-4 -ml-0.5") do |s|
          s.path(d: "M2 2.75A.75.75 0 0 1 2.75 2h9.5a.75.75 0 0 1 0 1.5h-9.5A.75.75 0 0 1 2 2.75ZM2 6.25a.75.75 0 0 1 .75-.75h5.5a.75.75 0 0 1 0 1.5h-5.5A.75.75 0 0 1 2 6.25Zm0 3.5A.75.75 0 0 1 2.75 9h3.5a.75.75 0 0 1 0 1.5h-3.5A.75.75 0 0 1 2 9.75ZM9.22 9.53a.75.75 0 0 1 0-1.06l2.25-2.25a.75.75 0 0 1 1.06 0l2.25 2.25a.75.75 0 0 1-1.06 1.06l-.97-.97v5.69a.75.75 0 0 1-1.5 0V8.56l-.97.97a.75.75 0 0 1-1.06 0Z")
        end
        span { "Sort" }
      end
    end
  end
end
```

#### Features

- ✅ Dark mode support
- ✅ Validation states (error with red styling)
- ✅ Disabled state
- ✅ Icons (leading/trailing)
- ✅ Add-ons (text labels)
- ✅ Inline dropdowns
- ✅ Attached buttons
- ✅ Grouped inputs with shared borders
- ✅ Multiple label styles (normal, inset, floating, hidden)
- ✅ Accessible (proper labels, ARIA attributes, error announcements)
- ✅ Mobile-optimized touch targets

---

### Select - Dropdown Selection

Both native HTML `<select>` and custom JavaScript-powered select menus.

#### Native Select (Simple & Fast)

For standard dropdown selection with keyboard navigation and accessibility built-in.

```ruby
render Cuy::Select.new(
  name: "country",
  label: "Country"
) do |select|
  select.option("United States", value: "us")
  select.option("Canada", value: "ca", selected: true)
  select.option("Mexico", value: "mx")
end
```

**With Option Groups:**

```ruby
render Cuy::Select.new(name: "timezone", label: "Timezone") do |select|
  select.optgroup("North America") do |group|
    group.option("Eastern Time", value: "est")
    group.option("Central Time", value: "cst")
    group.option("Pacific Time", value: "pst")
  end
  
  select.optgroup("Europe") do |group|
    group.option("London", value: "gmt")
    group.option("Paris", value: "cet")
  end
end
```

**API Reference - Native Select:**

```ruby
Cuy::Select.new(
  name: String,
  label: String | nil,
  hint: String | nil,
  error: String | nil,
  placeholder: String | nil,  # Adds disabled first option
  disabled: Boolean,
  multiple: Boolean,          # Allow multiple selection
  size: Integer | nil,        # Visible options (turns into listbox)
  **html_options
)

# Methods
select.option(text, value: nil, selected: false, disabled: false)
select.optgroup(label, &block)
```

#### Custom Select (Rich UI)

For advanced dropdowns with avatars, status indicators, search, and custom layouts. Uses Headless UI under the hood.

**Simple Custom Select:**

```ruby
render Cuy::CustomSelect.new(
  name: "assigned_to",
  label: "Assigned to",
  options: [
    { value: "1", label: "Wade Cooper" },
    { value: "2", label: "Arlene Mccoy", selected: true },
    { value: "3", label: "Devon Webb" }
  ]
)
```

**With Avatars:**

```ruby
render Cuy::CustomSelect.new(
  name: "user_id",
  label: "Assign to"
) do |select|
  select.option(value: "1") do |opt|
    opt.avatar(src: "/avatars/wade.jpg")
    opt.label("Wade Cooper")
  end
  
  select.option(value: "2", selected: true) do |opt|
    opt.avatar(src: "/avatars/arlene.jpg")
    opt.label("Arlene Mccoy")
  end
end
```

**With Status Indicators:**

```ruby
render Cuy::CustomSelect.new(
  name: "status",
  label: "Status"
) do |select|
  select.option(value: "active") do |opt|
    opt.status(:success)  # Green dot
    opt.label("Active")
  end
  
  select.option(value: "paused") do |opt|
    opt.status(:warning)  # Yellow dot
    opt.label("Paused")
  end
  
  select.option(value: "inactive") do |opt|
    opt.status(:gray)     # Gray dot
    opt.label("Inactive")
  end
end
```

**With Secondary Text:**

```ruby
render Cuy::CustomSelect.new(
  name: "plan",
  label: "Subscription Plan"
) do |select|
  select.option(value: "free") do |opt|
    opt.label("Free")
    opt.description("Basic features for individuals")
  end
  
  select.option(value: "pro", selected: true) do |opt|
    opt.label("Pro")
    opt.description("Advanced features for professionals")
    opt.badge("Popular", variant: :primary)
  end
  
  select.option(value: "enterprise") do |opt|
    opt.label("Enterprise")
    opt.description("Custom solutions for teams")
  end
end
```

**With Search/Filter:**

```ruby
render Cuy::CustomSelect.new(
  name: "user_id",
  label: "Select user",
  searchable: true,
  search_placeholder: "Search users..."
) do |select|
  User.all.each do |user|
    select.option(value: user.id) do |opt|
      opt.avatar(src: user.avatar_url)
      opt.label(user.name)
      opt.description(user.email)
    end
  end
end
```

**API Reference - Custom Select:**

```ruby
Cuy::CustomSelect.new(
  name: String,
  label: String | nil,
  hint: String | nil,
  error: String | nil,
  placeholder: String,        # Button text when nothing selected
  searchable: Boolean,        # Add search input
  search_placeholder: String,
  multiple: Boolean,          # Allow multiple selection
  options: Array | nil,       # Simple array of hashes
  **html_options
)

# Option builder methods
opt.avatar(src:, alt: nil, size: :sm)
opt.status(variant)  # :success, :warning, :error, :gray, :primary
opt.label(text)
opt.description(text)
opt.badge(text, variant: :primary)
opt.icon(name)       # Leading icon
```

#### Comparison: Native vs Custom

**Use Native Select when:**
- ✅ Simple dropdown with text options
- ✅ Need form to work without JavaScript
- ✅ Mobile-optimized (native pickers)
- ✅ Accessibility is critical (screen readers)
- ✅ Performance matters (large lists)

**Use Custom Select when:**
- ✅ Need rich content (avatars, status, descriptions)
- ✅ Want search/filter functionality
- ✅ Need custom styling beyond CSS
- ✅ Multi-select with tags/chips
- ✅ Want consistent UI across platforms

#### Complete Example: User Assignment Select

```ruby
class Components::UserSelect < Cuy::Component
  def initialize(name:, label:, selected: nil, users:)
    @name = name
    @label = label
    @selected = selected
    @users = users
  end

  def view_template
    render Cuy::CustomSelect.new(
      name: @name,
      label: @label,
      searchable: true,
      placeholder: "Select a user..."
    ) do |select|
      @users.each do |user|
        select.option(
          value: user.id,
          selected: user.id == @selected
        ) do |opt|
          opt.avatar(
            src: user.avatar_url,
            alt: user.name
          )
          
          opt.label(user.name)
          opt.description(user.email)
          
          if user.admin?
            opt.badge("Admin", variant: :primary)
          end
        end
      end
    end
  end
end
```

#### Implementation Notes

**Native Select Styling:**
- Uses `grid` layout to overlay chevron icon
- `appearance-none` removes browser default
- Custom chevron positioned with `col-start-1 row-start-1`
- Dark mode support via `dark:` variants

**Custom Select (Headless UI):**
- Based on `@headlessui/react` Listbox pattern
- Fully keyboard accessible (Arrow keys, Enter, Escape)
- Auto-positioning (anchored to button)
- Scrollable with max height
- Selected state with checkmark
- Focus management

**Mobile Considerations:**
- Native select uses OS picker on mobile
- Custom select may need mobile-specific styles
- Consider viewport height for dropdown positioning

---

### RadioGroup - Radio Button Selection

Radio buttons for mutually exclusive selections, with support for simple lists, inline layouts, descriptions, and card-style options.

#### Basic Usage

```ruby
render Cuy::RadioGroup.new(
  name: "notification_method",
  legend: "Notifications",
  hint: "How do you prefer to receive notifications?"
) do |group|
  group.radio("email", "Email", checked: true)
  group.radio("sms", "Phone (SMS)")
  group.radio("push", "Push notification")
end
```

#### API Reference

```ruby
Cuy::RadioGroup.new(
  name: String,                # Radio button name attribute
  legend: String | nil,        # Fieldset legend
  hint: String | nil,          # Help text below legend
  layout: Symbol,              # :stacked (default), :inline, :cards, :small_cards
  **html_options
)

# Radio methods
group.radio(
  value: String,
  label: String,
  checked: Boolean,
  disabled: Boolean,
  &block                       # For rich content
)
```

#### Layout Variants

##### Stacked List (Default)

Vertical list of radio buttons with labels.

```ruby
render Cuy::RadioGroup.new(
  name: "privacy",
  legend: "Privacy",
  layout: :stacked  # default
) do |group|
  group.radio("public", "Public access")
  group.radio("private", "Private to team", checked: true)
  group.radio("restricted", "Restricted")
end
```

##### Inline List

Horizontal layout for short lists.

```ruby
render Cuy::RadioGroup.new(
  name: "size",
  legend: "Size",
  layout: :inline
) do |group|
  group.radio("small", "Small")
  group.radio("medium", "Medium", checked: true)
  group.radio("large", "Large")
end
```

##### With Descriptions

Add description text below each option.

```ruby
render Cuy::RadioGroup.new(
  name: "plan",
  legend: "Choose your plan"
) do |group|
  group.radio("free", checked: true) do |r|
    r.label("Free")
    r.description("Basic features for individuals")
  end
  
  group.radio("pro") do |r|
    r.label("Pro")
    r.description("Advanced features and priority support")
  end
  
  group.radio("enterprise") do |r|
    r.label("Enterprise")
    r.description("Custom solutions for large teams")
  end
end
```

##### With Inline Descriptions

Description on the same line as label.

```ruby
render Cuy::RadioGroup.new(
  name: "frequency",
  legend: "Update frequency"
) do |group|
  group.radio("realtime", checked: true) do |r|
    r.label("Real-time")
    r.inline_description("Updates immediately")
  end
  
  group.radio("daily") do |r|
    r.label("Daily")
    r.inline_description("Updates once per day")
  end
end
```

##### Card Layout

Large, clickable cards with radio indicators.

```ruby
render Cuy::RadioGroup.new(
  name: "deployment",
  legend: "Deployment target",
  layout: :cards
) do |group|
  group.radio("cloud", checked: true) do |r|
    r.icon(:cloud)
    r.label("Cloud")
    r.description("Deploy to our managed cloud infrastructure")
  end
  
  group.radio("on_premise") do |r|
    r.icon(:server)
    r.label("On-Premise")
    r.description("Deploy to your own infrastructure")
  end
  
  group.radio("hybrid") do |r|
    r.icon(:globe)
    r.label("Hybrid")
    r.description("Combination of cloud and on-premise")
  end
end
```

**Card Layout:**
```
┌─────────────────────────────┐
│ [✓]  ☁️  Cloud             │
│ Deploy to our managed       │
│ cloud infrastructure        │
└─────────────────────────────┘
```

##### Small Card Layout

Compact card layout for multiple options.

```ruby
render Cuy::RadioGroup.new(
  name: "color",
  legend: "Theme color",
  layout: :small_cards
) do |group|
  group.radio("indigo", checked: true) do |r|
    r.color_swatch("#6366f1")
    r.label("Indigo")
  end
  
  group.radio("blue") do |r|
    r.color_swatch("#3b82f6")
    r.label("Blue")
  end
  
  group.radio("green") do |r|
    r.color_swatch("#10b981")
    r.label("Green")
  end
end
```

**Small Cards:**
```
┌────┐ ┌────┐ ┌────┐
│[✓] │ │    │ │    │
│ ●  │ │ ●  │ │ ●  │
│Ind │ │Blue│ │Grn │
└────┘ └────┘ └────┘
```

##### Radio on Right

Radio button positioned on the right side.

```ruby
render Cuy::RadioGroup.new(
  name: "priority",
  legend: "Select priority",
  radio_position: :right
) do |group|
  group.radio("low") do |r|
    r.label("Low Priority")
    r.description("Process in background")
  end
  
  group.radio("high", checked: true) do |r|
    r.label("High Priority")
    r.description("Process immediately")
    r.badge("Recommended", variant: :primary)
  end
end
```

#### Advanced Examples

##### With Icons and Badges

```ruby
render Cuy::RadioGroup.new(
  name: "subscription",
  legend: "Choose subscription"
) do |group|
  group.radio("basic") do |r|
    r.icon(:user)
    r.label("Basic")
    r.description("$9/month • For individuals")
  end
  
  group.radio("pro", checked: true) do |r|
    r.icon(:users)
    r.label("Professional")
    r.description("$29/month • For small teams")
    r.badge("Popular", variant: :primary)
  end
  
  group.radio("enterprise") do |r|
    r.icon(:building)
    r.label("Enterprise")
    r.description("Custom pricing • For organizations")
    r.badge("Contact Sales", variant: :gray)
  end
end
```

##### Branded/Colored Options

```ruby
render Cuy::RadioGroup.new(
  name: "environment",
  legend: "Deploy to",
  layout: :cards
) do |group|
  group.radio("production") do |r|
    r.label("Production")
    r.description("Live environment")
    r.status(:success)  # Green indicator
  end
  
  group.radio("staging", checked: true) do |r|
    r.label("Staging")
    r.description("Pre-production testing")
    r.status(:warning)  # Yellow indicator
  end
  
  group.radio("development") do |r|
    r.label("Development")
    r.description("Local development")
    r.status(:gray)  # Gray indicator
  end
end
```

##### With Disabled Options

```ruby
render Cuy::RadioGroup.new(
  name: "shipping",
  legend: "Shipping method"
) do |group|
  group.radio("standard", checked: true) do |r|
    r.label("Standard Shipping")
    r.description("5-7 business days • Free")
  end
  
  group.radio("express") do |r|
    r.label("Express Shipping")
    r.description("2-3 business days • $10")
  end
  
  group.radio("overnight", disabled: true) do |r|
    r.label("Overnight Shipping")
    r.description("Next day • Unavailable")
  end
end
```

#### Complete Example: Payment Method Selector

```ruby
class Components::PaymentMethodSelector < Cuy::Component
  def initialize(name:, selected: nil)
    @name = name
    @selected = selected
  end

  def view_template
    render Cuy::RadioGroup.new(
      name: @name,
      legend: "Payment method",
      hint: "Select how you'd like to pay",
      layout: :cards
    ) do |group|
      # Credit Card
      group.radio("credit_card", checked: @selected == "credit_card") do |r|
        r.icon(:credit_card)
        r.label("Credit Card")
        r.description("Visa, Mastercard, Amex")
        r.badge("Instant", variant: :success)
      end
      
      # Bank Transfer
      group.radio("bank_transfer", checked: @selected == "bank_transfer") do |r|
        r.icon(:bank)
        r.label("Bank Transfer")
        r.description("Direct bank account transfer")
        r.inline_hint("2-3 business days")
      end
      
      # PayPal
      group.radio("paypal", checked: @selected == "paypal") do |r|
        r.icon(:paypal)  # Custom PayPal icon
        r.label("PayPal")
        r.description("Pay with your PayPal account")
      end
      
      # Cryptocurrency (disabled)
      group.radio("crypto", disabled: true) do |r|
        r.icon(:bitcoin)
        r.label("Cryptocurrency")
        r.description("Coming soon")
      end
    end
  end
end
```

#### Styling Notes

**Radio Button:**
- Custom styled with `appearance-none`
- Circle shape with `rounded-full`
- Checked state shows inner dot with `::before` pseudo-element
- Focus ring with `focus-visible:outline`
- Disabled state with reduced opacity

**Layouts:**
- **Stacked**: `space-y-6` between options
- **Inline**: `flex gap-x-6` horizontal layout
- **Cards**: Full-width clickable cards with hover states
- **Small Cards**: Grid layout with compact cards

**Accessibility:**
- Proper `<fieldset>` and `<legend>` structure
- Radio buttons grouped by `name` attribute
- Labels associated with inputs via `for`/`id`
- Keyboard navigation (arrow keys, space, tab)
- Focus indicators
- Screen reader friendly

**Dark Mode:**
- All variants support dark mode
- Custom colors for borders and backgrounds
- Appropriate contrast ratios

---

### CheckboxGroup - Multiple Selection

Checkbox groups for selecting multiple options, with support for descriptions, inline layouts, and various visual styles.

#### Basic Usage

```ruby
render Cuy::CheckboxGroup.new(
  legend: "Notifications",
  hint: "Choose which notifications you want to receive"
) do |group|
  group.checkbox("comments", "Comments", checked: true)
  group.checkbox("candidates", "Candidates")
  group.checkbox("offers", "Offers")
end
```

#### API Reference

```ruby
Cuy::CheckboxGroup.new(
  legend: String | nil,        # Fieldset legend
  hint: String | nil,          # Help text below legend
  layout: Symbol,              # :stacked (default), :checkbox_right
  style: Symbol,               # :simple (default), :divided, :bordered
  **options                    # Additional fieldset attributes
)
```

**Checkbox Method:**

```ruby
group.checkbox(
  value,                       # Checkbox value/name
  label,                       # Label text
  description: nil,            # Optional description
  inline_description: false,   # Show description inline with label
  checked: false,              # Pre-checked state
  disabled: false,             # Disabled state
  **options                    # Additional input attributes
)
```

#### Variants

##### Simple List

```ruby
render Cuy::CheckboxGroup.new(
  legend: "Notifications"
) do |group|
  group.checkbox("comments", "Comments", checked: true)
  group.checkbox("candidates", "Candidates")
  group.checkbox("offers", "Offers")
end
```

##### With Descriptions

```ruby
render Cuy::CheckboxGroup.new(
  legend: "Notifications"
) do |group|
  group.checkbox(
    "comments",
    "Comments",
    description: "Get notified when someone posts a comment on a posting.",
    checked: true
  )
  group.checkbox(
    "candidates",
    "Candidates",
    description: "Get notified when a candidate applies for a job."
  )
  group.checkbox(
    "offers",
    "Offers",
    description: "Get notified when a candidate accepts or rejects an offer."
  )
end
```

##### Inline Descriptions

```ruby
render Cuy::CheckboxGroup.new(
  legend: "Notifications"
) do |group|
  group.checkbox(
    "comments",
    "New comments",
    description: "so you always know what's happening.",
    inline_description: true,
    checked: true
  )
  group.checkbox(
    "candidates",
    "New candidates",
    description: "who apply for any open postings.",
    inline_description: true
  )
end
```

**Renders as:**
```
[✓] New comments so you always know what's happening.
[ ] New candidates who apply for any open postings.
```

##### Checkbox on Right

```ruby
render Cuy::CheckboxGroup.new(
  legend: "Notifications",
  layout: :checkbox_right,
  style: :divided
) do |group|
  group.checkbox(
    "comments",
    "Comments",
    description: "Get notified when someone posts a comment.",
    checked: true
  )
  group.checkbox(
    "candidates",
    "Candidates",
    description: "Get notified when a candidate applies."
  )
end
```

##### Simple List with Heading

```ruby
render Cuy::CheckboxGroup.new(
  legend: "Members",
  style: :bordered
) do |group|
  group.checkbox("person-1", "Annette Black", checked: true)
  group.checkbox("person-2", "Cody Fisher", checked: true)
  group.checkbox("person-3", "Courtney Henry")
  group.checkbox("person-4", "Kathryn Murphy")
  group.checkbox("person-5", "Theresa Webb")
end
```

#### Layout Options

**`:stacked`** (default)
- Checkboxes on the left
- Labels and descriptions on the right
- Standard vertical spacing

**`:checkbox_right`**
- Labels and descriptions on the left
- Checkboxes aligned to the right
- Good for longer content

#### Style Options

**`:simple`** (default)
- No borders
- Clean spacing with `space-y-5`

**`:divided`**
- Divider lines between items
- Top and bottom borders on fieldset

**`:bordered`**
- Top and bottom borders on fieldset
- Divided items
- Good for lists with headings

#### Complete Example

```ruby
# app/components/notification_settings.rb
class NotificationSettings < Cuy::Component
  def initialize(user:)
    @user = user
  end

  def view_template
    render Cuy::Form.new(action: update_notifications_path, method: :patch) do |form|
      form.section("Email Notifications", "Choose what you want to be notified about") do
        render Cuy::CheckboxGroup.new(
          legend: "Push Notifications",
          hint: "These are delivered via SMS to your mobile phone."
        ) do |group|
          group.checkbox(
            "push_comments",
            "Comments",
            description: "Get notified when someone posts a comment.",
            checked: @user.push_comments?
          )
          group.checkbox(
            "push_candidates",
            "Candidates",
            description: "Get notified when a candidate applies for a job.",
            checked: @user.push_candidates?
          )
          group.checkbox(
            "push_offers",
            "Offers",
            description: "Get notified when a candidate accepts or rejects an offer.",
            checked: @user.push_offers?
          )
        end

        render Cuy::CheckboxGroup.new(
          legend: "Email Notifications",
          style: :divided,
          layout: :checkbox_right
        ) do |group|
          group.checkbox(
            "email_marketing",
            "Marketing emails",
            description: "Receive emails about new products and features.",
            checked: @user.email_marketing?
          )
          group.checkbox(
            "email_security",
            "Security emails",
            description: "Receive emails about your account security.",
            checked: @user.email_security?,
            disabled: true  # Always on
          )
        end
      end

      form.actions do
        render Cuy::Button.new(type: :submit, variant: :primary) { "Save preferences" }
      end
    end
  end
end
```

#### Accessibility Notes

- Always use `<fieldset>` and `<legend>` for grouped checkboxes
- Use `aria-describedby` to link descriptions to checkboxes
- Screen reader text with `.sr-only` for inline descriptions
- Support keyboard navigation (Space to toggle)
- Use `:disabled` to prevent interaction, not just visual styling

#### Implementation Notes

**Checkbox Structure:**
```html
<div class="group grid size-4 grid-cols-1">
  <input type="checkbox" class="col-start-1 row-start-1 appearance-none rounded-sm ..." />
  <svg class="pointer-events-none col-start-1 row-start-1 ...">
    <!-- Checkmark icon -->
    <path class="opacity-0 group-has-checked:opacity-100" ... />
    <!-- Indeterminate icon -->
    <path class="opacity-0 group-has-indeterminate:opacity-100" ... />
  </svg>
</div>
```

**Key Classes:**
- Checkbox: `appearance-none rounded-sm border checked:bg-indigo-600`
- Overlaid SVG: `pointer-events-none col-start-1 row-start-1`
- Show on checked: `group-has-checked:opacity-100`
- Indeterminate support: `group-has-indeterminate:opacity-100`

---

### Toggle - On/Off Switch

Toggle switches for binary on/off states, with support for labels, descriptions, icons, and various layouts.

#### Basic Usage

```ruby
render Cuy::Toggle.new(
  name: "notifications",
  label: "Enable notifications"
)
```

#### API Reference

```ruby
Cuy::Toggle.new(
  name: String,                # Input name attribute
  label: String | nil,         # Label text
  description: String | nil,   # Description/hint text
  checked: false,              # Initial checked state
  disabled: false,             # Disabled state
  size: :normal,               # :normal or :short
  label_position: :left,       # :left, :right, or :none
  with_icons: false,           # Show checkmark/X icons inside knob
  **options                    # Additional input attributes
)
```

#### Variants

##### Simple Toggle

```ruby
render Cuy::Toggle.new(
  name: "setting",
  label_position: :none
)
```

##### Short Toggle

Compact version with tighter spacing:

```ruby
render Cuy::Toggle.new(
  name: "setting",
  size: :short,
  label_position: :none
)
```

##### With Icons

Shows checkmark when on, X when off:

```ruby
render Cuy::Toggle.new(
  name: "setting",
  with_icons: true,
  label_position: :none
)
```

##### With Left Label and Description

```ruby
render Cuy::Toggle.new(
  name: "availability",
  label: "Available to hire",
  description: "Nulla amet tempus sit accumsan. Aliquet turpis sed sit lacinia.",
  label_position: :left
)
```

##### With Right Label

```ruby
render Cuy::Toggle.new(
  name: "annual_billing",
  label: "Annual billing",
  description: "(Save 10%)",
  label_position: :right
)
```

#### Complete Example

```ruby
# app/components/user_settings.rb
class UserSettings < Cuy::Component
  def initialize(user:)
    @user = user
  end

  def view_template
    render Cuy::Form.new(action: update_settings_path, method: :patch) do |form|
      form.section("Notifications", "Manage how you receive notifications") do
        # Toggle with label on left
        render Cuy::Toggle.new(
          name: "email_notifications",
          label: "Email notifications",
          description: "Receive email about your account activity.",
          checked: @user.email_notifications?,
          label_position: :left
        )

        # Toggle with label on right (billing style)
        render Cuy::Toggle.new(
          name: "annual_billing",
          label: "Annual billing",
          description: "(Save 10%)",
          checked: @user.annual_billing?,
          label_position: :right
        )

        # Toggle with icons
        render Cuy::Toggle.new(
          name: "dark_mode",
          label: "Dark mode",
          with_icons: true,
          checked: @user.dark_mode?,
          label_position: :left
        )

        # Compact toggle
        render Cuy::Toggle.new(
          name: "compact_view",
          label: "Compact view",
          size: :short,
          checked: @user.compact_view?,
          label_position: :left
        )
      end

      form.actions do
        render Cuy::Button.new(type: :submit, variant: :primary) { "Save preferences" }
      end
    end
  end
end
```

#### Size Options

**`:normal`** (default)
- Width: `w-11` (44px)
- Knob: `size-5` (20px)
- Padding: `p-0.5`

**`:short`**
- Width: `w-10` (40px)
- Knob: `size-5` (20px)
- Height: `h-5` (20px)
- More compact appearance

#### Label Position Options

**`:left`** (default)
- Label and description on the left
- Toggle on the right
- Uses `justify-between` layout

**`:right`**
- Toggle on the left
- Label and description on the right
- Useful for billing/pricing toggles

**`:none`**
- No label, just the toggle
- Use `aria-label` for accessibility

#### Accessibility Notes

- Always provide either a visible label or `aria-label`
- Use `aria-labelledby` to link to external label
- Use `aria-describedby` to link to description
- Support keyboard navigation (Space/Enter to toggle)
- Support `:disabled` state
- Clear focus indicators with `has-focus-visible:outline-2`

#### Implementation Notes

**Toggle Structure:**
```html
<div class="group relative inline-flex w-11 ... has-checked:bg-indigo-600">
  <span class="size-5 ... group-has-checked:translate-x-5"></span>
  <input type="checkbox" class="absolute inset-0 appearance-none" />
</div>
```

**With Icons Structure:**
```html
<span class="relative size-5 rounded-full ...">
  <!-- X icon (off state) -->
  <span class="... opacity-100 group-has-checked:opacity-0">
    <svg>...</svg>
  </span>
  <!-- Checkmark icon (on state) -->
  <span class="... opacity-0 group-has-checked:opacity-100">
    <svg>...</svg>
  </span>
</span>
```

**Key Classes:**
- Container: `group relative inline-flex rounded-full`
- Background transitions: `transition-colors duration-200 ease-in-out`
- Knob: `rounded-full bg-white shadow-xs`
- Knob animation: `transition-transform duration-200 ease-in-out`
- Checked state: `has-checked:bg-indigo-600 group-has-checked:translate-x-5`
- Focus: `has-focus-visible:outline-2 outline-offset-2`

**Icon Transitions:**
- Off icon: `opacity-100 duration-200 ease-in group-has-checked:opacity-0 group-has-checked:duration-100 group-has-checked:ease-out`
- On icon: `opacity-0 duration-100 ease-out group-has-checked:opacity-100 group-has-checked:duration-200 group-has-checked:ease-in`

---

### Combobox - Searchable Dropdown (Autocomplete)

Autocomplete input with live filtering, supporting rich content like avatars, status indicators, and secondary text.

#### Basic Usage

```ruby
render Cuy::Combobox.new(
  name: "assignee",
  label: "Assigned to",
  placeholder: "Search users..."
) do |combo|
  combo.option("Leslie Alexander", value: "1")
  combo.option("Michael Foster", value: "2")
  combo.option("Dries Vincent", value: "3")
end
```

#### API Reference

```ruby
Cuy::Combobox.new(
  name: String,                # Input name attribute
  label: String | nil,         # Label text
  placeholder: String | nil,   # Placeholder text
  value: String | nil,         # Selected value
  required: false,             # Required field
  disabled: false,             # Disabled state
  error: String | nil,         # Error message
  hint: String | nil,          # Help text
  **options                    # Additional attributes
)
```

#### Variants

##### Simple Text Options

```ruby
render Cuy::Combobox.new(name: "user", label: "Assigned to") do |combo|
  combo.option("Leslie Alexander", value: "1")
  combo.option("Michael Foster", value: "2")
  combo.option("Dries Vincent", value: "3")
end
```

##### With Avatars

```ruby
render Cuy::Combobox.new(name: "user", label: "Assigned to") do |combo|
  combo.option("Leslie Alexander", value: "1", avatar: user.avatar_url)
  combo.option("Michael Foster", value: "2", avatar: user2.avatar_url)
  combo.option("Dries Vincent", value: "3", avatar: user3.avatar_url)
end
```

##### With Status Indicators

```ruby
render Cuy::Combobox.new(name: "user", label: "Assigned to") do |combo|
  combo.option("Leslie Alexander", value: "1", status: :online)
  combo.option("Michael Foster", value: "2", status: :offline)
  combo.option("Dries Vincent", value: "3", status: :offline)
  combo.option("Lindsay Walton", value: "4", status: :online)
end
```

**Status Colors:**
- `:online` → Green dot (`bg-green-400`)
- `:offline` → Gray dot (`bg-gray-200`)
- `:busy` → Red dot (`bg-red-400`)
- `:away` → Yellow dot (`bg-yellow-400`)

##### With Secondary Text

```ruby
render Cuy::Combobox.new(name: "user", label: "Assigned to") do |combo|
  combo.option("Leslie Alexander", value: "1", secondary: "@lesliealexander")
  combo.option("Michael Foster", value: "2", secondary: "@michaelfoster")
  combo.option("Dries Vincent", value: "3", secondary: "@driesvincent")
end
```

##### Rich Options (All Features)

```ruby
render Cuy::Combobox.new(name: "user", label: "Assigned to") do |combo|
  combo.option(
    "Leslie Alexander",
    value: "1",
    avatar: user.avatar_url,
    status: :online,
    secondary: "@lesliealexander"
  )
  
  combo.option(
    "Michael Foster",
    value: "2",
    avatar: user2.avatar_url,
    status: :offline,
    secondary: "michael@example.com"
  )
end
```

#### Custom Option Content

For complete control, use the block form:

```ruby
render Cuy::Combobox.new(name: "user", label: "Assigned to") do |combo|
  combo.option(value: "1") do
    img(src: user.avatar_url, class: "size-6 rounded-full")
    div(class: "ml-3") do
      div(class: "font-medium") { "Leslie Alexander" }
      div(class: "text-sm text-gray-500") { "Engineering" }
    end
  end
end
```

#### Implementation Notes

**JavaScript Integration:**
- Uses Headless UI `Combobox` or custom `<el-autocomplete>` web component
- Filters options as user types
- Keyboard navigation (↑/↓ arrows, Enter, Escape)
- Popover positioning with anchor API

**Accessibility:**
- `role="combobox"` with proper ARIA attributes
- `aria-expanded`, `aria-activedescendant`
- Screen reader announcements for filtering results
- Keyboard accessible

**Styling:**
- Active option: `aria-selected:bg-indigo-600 aria-selected:text-white`
- Max height dropdown: `max-h-60 overflow-auto`
- Smooth transitions on open/close

#### Working Example

```ruby
# app/components/shared/user_combobox.rb
module Components
  module Shared
    class UserCombobox < Cuy::Component
      def initialize(users:, selected: nil, name: "user_id")
        @users = users
        @selected = selected
        @name = name
      end

      def view_template
        render Cuy::Combobox.new(
          name: @name,
          label: "Assign to user",
          value: @selected&.id,
          placeholder: "Search users..."
        ) do |combo|
          @users.each do |user|
            combo.option(
              user.name,
              value: user.id,
              avatar: user.avatar_url,
              status: user.online? ? :online : :offline,
              secondary: user.email
            )
          end
        end
      end
    end
  end
end

# Usage in view
render Components::Shared::UserCombobox.new(
  users: User.active,
  selected: @deal.assignee
)
```

---

## Layout Components

### Card - Container with Elevation

Content containers with various header/footer combinations, responsive edge-to-edge mobile layouts, and "well" variants for nested content.

#### Basic Usage

```ruby
render Cuy::Card.new do
  h3(class: "text-lg font-medium") { "Card Title" }
  p(class: "mt-2 text-gray-600") { "Card content goes here." }
end
```

#### API Reference

```ruby
Cuy::Card.new(
  variant: :card,              # :card (default), :well
  mobile: :default,            # :default, :edge_to_edge
  padding: true,               # Apply default padding
  **options                    # Additional HTML attributes
)
```

#### Variants

##### Basic Card

Simple elevated container with shadow and rounded corners:

```ruby
render Cuy::Card.new do
  # Your content
end
```

**Styling:**
- Light: `bg-white shadow-sm rounded-lg`
- Dark: `bg-gray-800/50 outline outline-white/10`

##### Card with Header

```ruby
render Cuy::Card.new do |card|
  card.header do
    h3(class: "text-base font-semibold") { "Projects" }
  end
  
  card.body do
    p { "Main content..." }
  end
end
```

##### Card with Footer

```ruby
render Cuy::Card.new do |card|
  card.body do
    p { "Main content..." }
  end
  
  card.footer do
    button { "Save" }
    button { "Cancel" }
  end
end
```

##### Card with Header and Footer

```ruby
render Cuy::Card.new do |card|
  card.header do
    h3 { "Edit Profile" }
    p(class: "text-sm text-gray-500") { "Update your information" }
  end
  
  card.body do
    # Form fields
  end
  
  card.footer do
    button(class: "btn-primary") { "Save" }
    button(class: "btn-secondary") { "Cancel" }
  end
end
```

##### Card with Gray Footer

Visually separate footer with background color:

```ruby
render Cuy::Card.new do |card|
  card.body do
    p { "Content here..." }
  end
  
  card.footer(background: :gray) do
    div(class: "flex justify-end gap-3") do
      button { "Cancel" }
      button { "Submit" }
    end
  end
end
```

**Footer Styling:**
- `bg-gray-50 dark:bg-white/5`

##### Card with Gray Body

Header stands out, body has subtle background:

```ruby
render Cuy::Card.new do |card|
  card.header do
    h3 { "Notifications" }
  end
  
  card.body(background: :gray) do
    # List of notifications
  end
end
```

##### Edge-to-Edge on Mobile

Card removes padding/border-radius on mobile for full-width layout:

```ruby
render Cuy::Card.new(mobile: :edge_to_edge) do |card|
  card.header do
    h3 { "Responsive Card" }
  end
  
  card.body do
    p { "Content goes edge-to-edge on mobile" }
  end
end
```

**Mobile Classes:**
- No rounded corners on mobile: `rounded-none sm:rounded-lg`
- No side padding on mobile: `px-0 sm:px-6`

##### Well - Nested Content Container

Inset appearance for nested/secondary content:

```ruby
render Cuy::Card.new(variant: :well) do
  p(class: "text-sm text-gray-700") do
    strong { "Note:" }
    whitespace
    text "This is supplementary information."
  end
end
```

**Well Styling:**
- Light: `bg-gray-50 ring-1 ring-inset ring-black/5`
- Dark: `bg-white/5 ring-1 ring-inset ring-white/10`

##### Well on Gray Background

Use this variant when page background is already gray:

```ruby
# Page with gray background
div(class: "bg-gray-100") do
  render Cuy::Card.new(variant: :well, background: :gray) do
    p { "Well stands out on gray background" }
  end
end
```

**Well on Gray Styling:**
- Light: `bg-white ring-1 ring-black/5`
- Dark: `bg-gray-800/50 ring-1 ring-white/10`

#### Complete Example

```ruby
# app/views/deals/show.rb
class Views::Deals::Show < Views::Base
  def view_template
    render Cuy::Card.new(mobile: :edge_to_edge) do |card|
      # Header with actions
      card.header do
        div(class: "flex items-center justify-between") do
          div do
            h2(class: "text-xl font-semibold") { @deal.title }
            p(class: "text-sm text-gray-500") { @deal.company.name }
          end
          
          div(class: "flex gap-2") do
            render Cuy::Button.new(variant: :secondary, size: :sm) { "Edit" }
            render Cuy::Button.new(variant: :danger, size: :sm) { "Delete" }
          end
        end
      end
      
      # Main content
      card.body do
        # Deal details
        render Cuy::DescriptionList.new do |dl|
          dl.item("Amount", number_to_currency(@deal.amount))
          dl.item("Stage", @deal.stage)
          dl.item("Close Date", @deal.close_date)
        end
        
        # Notes section (well inside card)
        div(class: "mt-6") do
          h3(class: "text-base font-medium mb-3") { "Notes" }
          
          render Cuy::Card.new(variant: :well) do
            p(class: "text-sm text-gray-700") { @deal.notes }
          end
        end
      end
      
      # Footer with actions
      card.footer(background: :gray) do
        div(class: "flex justify-between") do
          span(class: "text-sm text-gray-500") do
            text "Last updated "
            time_ago_in_words(@deal.updated_at)
            text " ago"
          end
          
          div(class: "flex gap-3") do
            render Cuy::Button.new(variant: :outline) { "Cancel" }
            render Cuy::Button.new(variant: :primary) { "Save Changes" }
          end
        end
      end
    end
  end
end
```

#### Layout Strategies

**Standard Layout:**
```ruby
# Full-width cards with consistent spacing
div(class: "space-y-6") do
  render Cuy::Card.new { ... }
  render Cuy::Card.new { ... }
end
```

**Grid Layout:**
```ruby
# Cards in responsive grid
div(class: "grid gap-6 sm:grid-cols-2 lg:grid-cols-3") do
  render Cuy::Card.new { ... }
  render Cuy::Card.new { ... }
  render Cuy::Card.new { ... }
end
```

**Nested Cards:**
```ruby
# Main card with nested wells
render Cuy::Card.new do |card|
  card.body do
    # Primary content
    
    # Nested well for related info
    render Cuy::Card.new(variant: :well) do
      p { "Related information" }
    end
  end
end
```

#### Design Notes

**When to Use Card vs Well:**
- **Card**: Primary content containers, main UI sections
- **Well**: Secondary/supplementary content, nested information, callouts

**Shadow vs Outline:**
- **Light mode**: Uses `shadow-sm` for subtle elevation
- **Dark mode**: Uses `outline` to avoid harsh shadows

**Responsive Considerations:**
- Use `mobile: :edge_to_edge` for mobile-first layouts
- Cards automatically adapt padding on mobile
- Consider full-width cards on mobile, grid on desktop

---

More components coming soon! Check the [README](./README.md) for the full component list.

