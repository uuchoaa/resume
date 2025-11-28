// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Modal functionality
document.addEventListener('DOMContentLoaded', () => {
  // Open modal with animation
  document.addEventListener('click', (e) => {
    const trigger = e.target.closest('[data-modal-target]');
    if (trigger) {
      e.preventDefault();
      const modalId = trigger.getAttribute('data-modal-target');
      const modal = document.getElementById(modalId);
      if (modal) {
        const backdrop = modal.querySelector('[data-modal-backdrop]');
        const panel = modal.querySelector('[data-modal-panel]');
        
        // Show modal
        modal.classList.remove('hidden');
        
        // Trigger animations
        requestAnimationFrame(() => {
          backdrop?.classList.remove('opacity-0');
          backdrop?.classList.add('opacity-100');
          
          panel?.classList.remove('translate-y-4', 'opacity-0', 'sm:scale-95');
          panel?.classList.add('translate-y-0', 'opacity-100', 'sm:scale-100');
        });
      }
    }
  });

  // Close modal with animation
  const closeModal = (modalId) => {
    const modal = document.getElementById(modalId);
    if (modal) {
      const backdrop = modal.querySelector('[data-modal-backdrop]');
      const panel = modal.querySelector('[data-modal-panel]');
      
      // Animate out
      backdrop?.classList.remove('opacity-100');
      backdrop?.classList.add('opacity-0');
      
      panel?.classList.remove('translate-y-0', 'opacity-100', 'sm:scale-100');
      panel?.classList.add('translate-y-4', 'opacity-0', 'sm:scale-95');
      
      // Hide after animation
      setTimeout(() => {
        modal.classList.add('hidden');
      }, 300);
    }
  };

  // Close modal button
  document.addEventListener('click', (e) => {
    const closeBtn = e.target.closest('[data-modal-close]');
    if (closeBtn) {
      e.preventDefault();
      const modalId = closeBtn.getAttribute('data-modal-close');
      closeModal(modalId);
    }
  });

  // Close modal when clicking backdrop
  document.addEventListener('click', (e) => {
    const backdrop = e.target.closest('[data-modal-backdrop]');
    if (backdrop) {
      const modalId = backdrop.getAttribute('data-modal-backdrop');
      closeModal(modalId);
    }
  });

  // Close modal with Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      const openModal = document.querySelector('dialog:not(.hidden)');
      if (openModal) {
        closeModal(openModal.id);
      }
    }
  });
});
