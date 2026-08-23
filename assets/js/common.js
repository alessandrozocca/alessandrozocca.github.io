$(document).ready(function () {
  // Toggle publication details while keeping button state available to assistive technology.
  $(".publications button[data-toggle-section]").click(function () {
    const button = $(this);
    const entry = button.closest(".row");
    const target = document.getElementById(button.attr("data-toggle-section"));
    const willOpen = target && !target.classList.contains("open");

    entry.find("button[data-toggle-section]").attr("aria-expanded", "false");
    entry.find(".hidden.open").removeClass("open");

    if (target && willOpen) {
      target.classList.add("open");
      button.attr("aria-expanded", "true");
    }
  });

  $(".publications button.more-authors").click(function () {
    const button = $(this);
    const expanded = button.attr("aria-expanded") === "true";
    button.attr("aria-expanded", String(!expanded));
    button.find(".more-authors-collapsed").prop("hidden", !expanded);
    button.find(".more-authors-expanded").prop("hidden", expanded);
  });
  $("a").removeClass("waves-effect waves-light");

  // bootstrap-toc
  if ($("#toc-sidebar").length) {
    // remove related publications years from the TOC
    $(".publications h2").each(function () {
      $(this).attr("data-toc-skip", "");
    });
    var navSelector = "#toc-sidebar";
    var $myNav = $(navSelector);
    Toc.init($myNav);
    $("body").scrollspy({
      target: navSelector,
    });
  }

  // add css to jupyter notebooks
  const cssLink = document.createElement("link");
  cssLink.href = "../css/jupyter.css";
  cssLink.rel = "stylesheet";
  cssLink.type = "text/css";

  let jupyterTheme = determineComputedTheme();

  $(".jupyter-notebook-iframe-container iframe").each(function () {
    $(this).contents().find("head").append(cssLink);

    if (jupyterTheme == "dark") {
      $(this).bind("load", function () {
        $(this).contents().find("body").attr({
          "data-jp-theme-light": "false",
          "data-jp-theme-name": "JupyterLab Dark",
        });
      });
    }
  });

  // trigger popovers
  $('[data-toggle="popover"]').popover({
    trigger: "hover",
  });
});
