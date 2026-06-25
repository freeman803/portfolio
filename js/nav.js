(function () {
  var toggle = document.querySelector(".nav-toggle");
  var nav = document.getElementById("primary-nav");
  if (!toggle || !nav) return;

  toggle.addEventListener("click", function () {
    var isOpen = nav.classList.toggle("open");
    toggle.setAttribute("aria-expanded", String(isOpen));
  });

  nav.addEventListener("click", function (e) {
    if (e.target.tagName === "A") {
      nav.classList.remove("open");
      toggle.setAttribute("aria-expanded", "false");
    }
  });
})();

(function () {
  var toc = document.querySelector(".toc");
  if (!toc || !("IntersectionObserver" in window)) return;

  var links = Array.prototype.slice.call(toc.querySelectorAll("a"));
  var linkById = {};
  var sections = [];

  links.forEach(function (link) {
    var id = (link.getAttribute("href") || "").replace(/^#/, "");
    var section = id && document.getElementById(id);
    if (section) {
      linkById[id] = link;
      sections.push(section);
    }
  });
  if (!sections.length) return;

  function setActive(id) {
    links.forEach(function (l) {
      l.classList.toggle("active", l === linkById[id]);
    });
  }

  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) setActive(entry.target.id);
      });
    },
    { rootMargin: "-80px 0px -70% 0px", threshold: 0 }
  );

  sections.forEach(function (section) {
    observer.observe(section);
  });
})();

(function () {
  var imgs = document.querySelectorAll(".image-grid img, .figure-grid img");
  if (!imgs.length) return;

  var overlay = document.createElement("div");
  overlay.className = "lightbox";
  overlay.setAttribute("role", "dialog");
  overlay.setAttribute("aria-modal", "true");
  overlay.setAttribute("aria-label", "Enlarged image");
  overlay.innerHTML =
    '<button class="lightbox__close" aria-label="Close">&times;</button>' +
    '<img class="lightbox__img" alt="">';
  document.body.appendChild(overlay);

  var overlayImg = overlay.querySelector(".lightbox__img");
  var closeBtn = overlay.querySelector(".lightbox__close");
  var lastTrigger = null;

  function open(trigger) {
    lastTrigger = trigger;
    overlayImg.src = trigger.currentSrc || trigger.src;
    overlayImg.alt = trigger.alt || "";
    overlay.classList.add("open");
    document.body.style.overflow = "hidden";
    closeBtn.focus();
  }

  function close() {
    overlay.classList.remove("open");
    document.body.style.overflow = "";
    overlayImg.removeAttribute("src");
    if (lastTrigger) {
      lastTrigger.focus();
      lastTrigger = null;
    }
  }

  // Make each thumbnail a keyboard-operable control
  imgs.forEach(function (img) {
    img.setAttribute("tabindex", "0");
    img.setAttribute("role", "button");
    img.setAttribute(
      "aria-label",
      (img.alt ? img.alt + " — " : "") + "view larger"
    );
    img.addEventListener("click", function () {
      open(img);
    });
    img.addEventListener("keydown", function (e) {
      if (e.key === "Enter" || e.key === " " || e.key === "Spacebar") {
        e.preventDefault();
        open(img);
      }
    });
  });

  closeBtn.addEventListener("click", close);
  overlay.addEventListener("click", function (e) {
    // Click on the backdrop (not the image) closes
    if (e.target === overlay || e.target === overlayImg) close();
  });

  document.addEventListener("keydown", function (e) {
    if (!overlay.classList.contains("open")) return;
    if (e.key === "Escape") {
      close();
    } else if (e.key === "Tab") {
      // Trap focus inside the dialog (only the close button is focusable)
      e.preventDefault();
      closeBtn.focus();
    }
  });
})();
