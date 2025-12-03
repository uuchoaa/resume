class Cuy::Navbar < Cuy::Base

  def initialize(current_path)
    @current_path = current_path
  end

  def view_template(&)
    div(class: "hidden sm:-my-px sm:ml-6 sm:flex sm:space-x-8", &)
  end

  def item(href, &)
    active_variant = "inline-flex items-center border-b-2 border-indigo-600 px-1 pt-1 text-sm font-medium text-gray-900"
    default_variant = "inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"

    a(class: @current_path.starts_with?(href) ? active_variant : default_variant, href:, &)
  end

end