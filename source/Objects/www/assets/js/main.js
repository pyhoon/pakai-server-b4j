/*!
 * Pakai Server Framework B4J Project Template v6.00beta by @pyhoon (https://github.com/pyhoon/pakai-server-b4j)
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
    const toast = new bootstrap.Toast(document.getElementById(toastId));
    toast.show();
}

function showSuccess(message) { showToast(message, 'success'); }
function showWarning(message) { showToast(message, 'warning'); }
function showDanger(message) { showToast(message, 'danger'); }

// Modal functions - NO variable declarations that could conflict
function closeCurrentModal() {
    const modalElement = document.querySelector('.modal.show');
    if (modalElement) {
        const bsModal = bootstrap.Modal.getInstance(modalElement);
        if (bsModal) {
            bsModal.hide();
        }
    }
}

// Modal management
document.addEventListener('htmx:afterSwap', function(e) {
    if (e.detail.target.id === 'modal-container') {
        const modalElement = e.detail.target.querySelector('.modal');
        if (modalElement) {
            const bsModal = new bootstrap.Modal(modalElement);
            
            modalElement.addEventListener('hidden.bs.modal', function() {
                document.getElementById('modal-container').innerHTML = '';
            });
            
            bsModal.show();
        }
    }
});

// Global error handler
document.addEventListener('htmx:responseError', function (event) {
  showError('Network error occurred. Please try again.');
});

// Fix bug for Chrome browser Blocked aria-hidden on an element
// Source - https://stackoverflow.com/questions/79159883/warning-blocked-aria-hidden-on-an-element-because-its-descendant-retained-focu
// Posted by Project Mayhem
// Retrieved 11/5/2025, License - CC-BY-SA 4.0
document.addEventListener("DOMContentLoaded", function () {
    document.addEventListener('hide.bs.modal', function (event) {
        if (document.activeElement) {
            document.activeElement.blur();
        }
    });
});
