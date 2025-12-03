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

More components coming soon! Check the [README](./README.md) for the full component list.

