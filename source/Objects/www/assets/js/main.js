/*!
 * Pakai Server Framework B4J Project Template v6.00alpha by @pyhoon (https://github.com/pyhoon/pakai-server-b4j)
 * Copyright (c) 2022-2025 Poon Yip Hoon (Aeric)
 * Licensed under MIT (https://github.com/pyhoon/pakai-server-b4j/blob/main/LICENSE)
 */
// // Auto-show modals when loaded
// document.addEventListener('htmx:afterSwap', function (e) {
//   if (e.detail.target.id === 'modal-container') {
//     const modal = new bootstrap.Modal(e.detail.target.querySelector('.modal'));
//     modal.show();
//   }
// });

// // Auto-clear modal container
// document.addEventListener('hidden.bs.modal', function () {
//   document.getElementById('modal-container').innerHTML = '';
// });

// Simple modal management
document.addEventListener('htmx:afterSwap', function(e) {
    if (e.detail.target.id === 'modal-container') {
        const modalElement = e.detail.target.querySelector('.modal');
        if (modalElement) {
            const modal = new bootstrap.Modal(modalElement);
            
            // Clean up when modal is closed
            modalElement.addEventListener('hidden.bs.modal', function() {
                document.getElementById('modal-container').innerHTML = '';
            });
            
            modal.show();
        }
    }
});

// Global error handler for network issues
document.addEventListener('htmx:responseError', function(event) {
    showError('Network error occurred. Please try again.');
});

// Toast functions
function showToast(message, type = 'info') {
  // Close modal
  const modal = bootstrap.Modal.getInstance(document.querySelector('.modal'));
  if (modal) modal.hide();

  const toastContainer = document.getElementById('toast-container');
  const toastId = 'toast-' + Date.now();

  const toastHTML = `
  <div id="${toastId}" class="toast align-items-center text-bg-${type} border-0" style="--bs-bg-opacity: .75;" role="alert">
      <div class="d-flex">
          <div class="toast-body">${message}</div>
          <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
  </div>
  `;

  toastContainer.insertAdjacentHTML('beforeend', toastHTML);

  const toastElement = document.getElementById(toastId);
  const toast = new bootstrap.Toast(toastElement);
  toast.show();

  // Remove from DOM after hide
  toastElement.addEventListener('hidden.bs.toast', function () {
    toastElement.remove();
  });
}

function showSuccess(message) { showToast(message, 'success'); }
function showError(message) { showToast(message, 'danger'); }
function showWarning(message) { showToast(message, 'warning'); }