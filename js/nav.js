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
  var imgs = document.querySelectorAll(".image-grid img");
  if (!imgs.length) return;

  var overlay = document.createElement("div");
  overlay.className = "lightbox";
  overlay.setAttribute("role", "dialog");
  overlay.setAttribute("aria-modal", "true");
  overlay.innerHTML =
    '<button class="lightbox__close" aria-label="Close">&times;</button>' +
    '<img class="lightbox__img" alt="">';
  document.body.appendChild(overlay);

  var overlayImg = overlay.querySelector(".lightbox__img");

  function open(src, alt) {
    overlayImg.src = src;
    overlayImg.alt = alt || "";
    overlay.classList.add("open");
    document.body.style.overflow = "hidden";
  }

  function close() {
    overlay.classList.remove("open");
    document.body.style.overflow = "";
    overlayImg.removeAttribute("src");
  }

  imgs.forEach(function (img) {
    img.addEventListener("click", function () {
      open(img.currentSrc || img.src, img.alt);
    });
  });

  overlay.addEventListener("click", close);
  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && overlay.classList.contains("open")) close();
  });
})();
