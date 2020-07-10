// Load the base64 encoded static asset and inject it into the DOM.

export const load = (encoded) => {
    get("#app").outerHTML = atob(encoded);
};

// Some helpful utility functions for DOM manipulation.

export const get = (selector) => document.querySelector(selector);
export const getAll = (selector) => document.querySelectorAll(selector);

export const show = (...selectors) =>
    selectors.forEach((selector) => get(selector).classList.remove("hidden"));

export const hide = (...selectors) =>
    selectors.forEach((selector) => get(selector).classList.add("hidden"));

export const update = (selector, html) => {
    get(selector).innerHTML = html;
};

export const bind = (selector, eventName, callback) =>
    getAll(selector).forEach((el) => el.addEventListener(eventName, callback));

// Clone an object with only the listed attributes.

export const pick = (obj, atts) =>
    atts.reduce((acc, val) => ({...acc, [val]: obj[val] }), {});