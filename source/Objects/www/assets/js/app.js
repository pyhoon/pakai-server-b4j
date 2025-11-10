/*!
 * Pakai Server Framework B4J Project Template v6.00 by @pyhoon (https://github.com/pyhoon/pakai-server-b4j)
 * Copyright (c) 2022-2025 Poon Yip Hoon (Aeric)
 * Licensed under MIT (https://github.com/pyhoon/pakai-server-b4j/blob/main/LICENSE)
 */
document.addEventListener('entity:changed', (e) => {
    const { entity, action, message, status } = e.detail || {};
    
    // Close the modal
    const modalEl = document.getElementById('modal-container');
    const modal = bootstrap.Modal.getInstance(modalEl);
    if (modal) modal.hide();
    
    // Update toast content
    const toastEl = document.getElementById('toast-container');
    const toastMsg = document.getElementById('toast-body');
    toastMsg.textContent = message || `${entity} ${action} successful`;
    
    // Reset & apply Bootstrap background class
    toastEl.className = `toast align-items-center border-0 text-bg-${status || 'success'}`;
    
    // Show toast
    const toast = bootstrap.Toast.getOrCreateInstance(toastEl);
    toast.show();
    console.info(`[HTMX] ${entity} ${action} completed`);
});

// Global error handler
document.addEventListener('htmx:responseError', function (event) {
    // Show toast
    document.getElementById('toast-body').textContent = 'Network error occurred. Please try again.';
    
    const toastEl = document.getElementById('toast-container');
    bootstrap.Toast.getOrCreateInstance(toastEl).show();

    console.info('Network error occurred.');
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