/*!
 * Pakai Server Framework B4J Project Template v6.00alpha by @pyhoon (https://github.com/pyhoon/pakai-server-b4j)
 * Copyright (c) 2022-2025 Poon Yip Hoon (Aeric)
 * Licensed under MIT (https://github.com/pyhoon/pakai-server-b4j/blob/main/LICENSE)
 */
// Toast functions
function showToast(message, type = 'info') {
  const toastContainer = document.getElementById('toast-container');
  const toastId = 'toast-' + Date.now();

  const toastHTML = `
        <div id="${toastId}" class="toast align-items-center text-bg-${type} border-0" role="alert">
            <div class="d-flex">
                <div class="toast-body">${message}</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
    `;

  toastContainer.insertAdjacentHTML('beforeend', toastHTML);
  const toastInstance = new bootstrap.Toast(document.getElementById(toastId));
  toastInstance.show();
}

function showSuccess(message) { showToast(message, 'success'); }
function showError(message) { showToast(message, 'danger'); }
function showWarning(message) { showToast(message, 'warning'); }

// Modal management - FIXED VARIABLE NAMES
document.addEventListener('htmx:afterSwap', function (e) {
  if (e.detail.target.id === 'modal-container') {
    const modalElement = e.detail.target.querySelector('.modal');
    if (modalElement) {
      // Use modalInstance instead of modal
      const modalInstance = new bootstrap.Modal(modalElement);

      modalElement.addEventListener('hidden.bs.modal', function () {
        document.getElementById('modal-container').innerHTML = '';
      });

      modalInstance.show();
    }
  }
});

// Global error handler
document.addEventListener('htmx:responseError', function (event) {
  showError('Network error occurred. Please try again.');
});