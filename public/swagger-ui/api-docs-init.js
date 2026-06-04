document.addEventListener("DOMContentLoaded", function () {
  var meta = document.querySelector('meta[name="swagger-spec-url"]');
  if (!meta || typeof SwaggerUIBundle === "undefined") return;

  window.ui = SwaggerUIBundle({
    url: meta.content,
    dom_id: "#swagger-ui",
    presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
    layout: "StandaloneLayout"
  });
});
