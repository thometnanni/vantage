// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

import "vantage-renderer";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let Hooks = {};

Hooks.ProjectionUpdate = {
  // projection_id() {
  //   return this.el.dataset.projectionId;
  // },
  keyframe_id() {
    return this.el.dataset.keyframeId;
  },
  mounted(e) {
    // this.el.addEventListener("vantage:set-focus", (e) => {
    //   this.pushEvent("vantage:set-focus", { id: this.projection_id() });
    // });
    this.el.addEventListener("vantage:set-position", (e) => {
      const [position_x, position_y, position_z] = e.detail.position;
      this.pushEvent("vantage:set-position", {
        id: this.keyframe_id(),
        position_x,
        position_y,
        position_z,
      });
    });
    this.el.addEventListener("vantage:set-rotation", (e) => {
      const [rotation_x, rotation_y, rotation_z] = e.detail.rotation;
      this.pushEvent("vantage:set-rotation", {
        id: this.keyframe_id(),
        rotation_x: rotation_x * (180 / Math.PI),
        rotation_y: rotation_y * (180 / Math.PI),
        rotation_z: rotation_z * (180 / Math.PI),
      });
    });
  },
};

Hooks.RendererUpdate = {
  mounted(e) {
    this.el.addEventListener("vantage:unlock-first-person", () => {
      this.pushEvent("vantage:unlock-first-person");
    });
  },
};

Hooks.OpenFileDialogue = {
  mounted() {
    this.el.addEventListener("click", () => {
      this.el.querySelector("input").click();
    });
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
