// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Modal functionality
document.addEventListener('DOMContentLoaded', () => {
  // Open modal
  document.addEventListener('click', (e) => {
    const trigger = e.target.closest('[data-modal-target]');
    if (trigger) {
      const modalId = trigger.getAttribute('data-modal-target');
      const modal = document.getElementById(modalId);
      if (modal) {
        modal.classList.remove('hidden');
      }
    }
  });

  // Close modal
  document.addEventListener('click', (e) => {
    const closeBtn = e.target.closest('[data-modal-close]');
    if (closeBtn) {
      const modalId = closeBtn.getAttribute('data-modal-close');
      const modal = document.getElementById(modalId);
      if (modal) {
        modal.classList.add('hidden');
      }
    }
  });

  // Close modal when clicking backdrop
  document.addEventListener('click', (e) => {
    if (e.target.classList.contains('bg-opacity-75')) {
      e.target.classList.add('hidden');
    }
  });
});
