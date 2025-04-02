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
import GetTimezone from "./hooks/GetTimezone";

import "vantage-renderer";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let Hooks = {
  GetTimezone,
};

function debounce(func, wait) {
  let timeout;
  return function (...args) {
    const context = this;
    clearTimeout(timeout);
    timeout = setTimeout(() => func.apply(context, args), wait);
  };
}

const soreData = {
  time: 0,
  time_volatile: 0,
};

const store = new Proxy(soreData, {
  get: function (target, prop) {
    // console.log({ type: "get", target, prop });
    return Reflect.get(target, prop);
  },
  set: function (target, prop, value) {
    // console.log({ type: "set", target, prop, value });
    if (prop === "time" || prop === "time_volatile") {
      const renderer = document.getElementById("renderer");
      if (renderer) {
        renderer.setAttribute("time", value);
      }
      const cursor = document.getElementById("timeline-cursor");
      const scrubber = document.getElementById("timeline-scrubber");
      if (cursor && scrubber) {
        const max_time = +scrubber.dataset.maxTime;
        const min_time = +scrubber.dataset.minTime;

        const perc_time = (value - min_time) / (max_time - min_time);

        cursor.style.left = `${perc_time * 100}%`;
      }

      // if (prop === "time") debouncedDispatchEvent(value);

      if (prop === "time")
        document.dispatchEvent(
          new CustomEvent("set-time", {
            detail: value,
          })
        );
    }
    return Reflect.set(target, prop, value);
  },
});

// const debouncedDispatchEvent = debounce((value) => {
//   document.dispatchEvent(
//     new CustomEvent("set-time", {
//       detail: value,
//     })
//   );
// }, 300);

Hooks.KeyframeUpdate = {
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
    this.el.addEventListener("vantage:set-fov", (e) => {
      const fov = e.detail.fov;
      this.pushEvent("vantage:set-fov", {
        id: this.keyframe_id(),
        fov,
      });
    });
  },
};

Hooks.ProjectionUpdate = {
  projection_id() {
    return this.el.dataset.projectionId;
  },
  mounted(e) {
    this.el.addEventListener("vantage:create-keyframe", (e) => {
      const [position_x, position_y, position_z] = e.detail.position;
      const [rotation_x, rotation_y, rotation_z] = e.detail.rotation;
      const fov = e.detail.fov;
      const far = e.detail.far;
      const time = e.detail.time;

      this.pushEvent("vantage:create-keyframe", {
        projection_id: this.projection_id(),
        position_x,
        position_y,
        position_z,
        rotation_x: rotation_x * (180 / Math.PI),
        rotation_y: rotation_y * (180 / Math.PI),
        rotation_z: rotation_z * (180 / Math.PI),
        fov,
        far,
        time,
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

Hooks.TimelineScrubber = {
  max_time() {
    return +this.el.dataset.maxTime;
  },
  min_time() {
    return +this.el.dataset.minTime;
  },
  mounted() {
    this.el.addEventListener("mousemove", (e) => {
      const rect = this.el.getBoundingClientRect();
      const offsetX = e.clientX - rect.left;
      store.time_volatile =
        (offsetX / rect.width) * (this.max_time() - this.min_time()) +
        this.min_time();
    });

    this.el.addEventListener("click", (e) => {
      const rect = this.el.getBoundingClientRect();
      const offsetX = e.clientX - rect.left;
      store.time =
        (offsetX / rect.width) * (this.max_time() - this.min_time()) +
        this.min_time();
    });

    this.el.addEventListener("mouseout", (e) => {
      // const rect = this.el.getBoundingClientRect();
      // const offsetX = e.clientX - rect.left;
      store.time_volatile = store.time;
      // (offsetX / rect.width) * (this.max_time() - this.min_time()) +
      // this.min_time();
    });

    document.addEventListener("set-time", (e) =>
      this.pushEvent("set-time", e.detail)
    );
  },
};

Hooks.DragItem = {
  item_id() {
    return this.el.dataset.itemId;
  },
  item_type() {
    return this.el.dataset.itemType;
  },
  mounted() {
    this.el.addEventListener("dragstart", (e) => {
      e.dataTransfer.effectAllowed = "move";
      const controller = new AbortController();
      const initialOpacity = this.el.style.getPropertyValue("opacity");
      requestAnimationFrame(() => this.el.style.setProperty("opacity", "0"));
      this.el.addEventListener(
        "dragend",
        (e) => {
          controller.abort();
          const items = [...this.el.parentElement.querySelectorAll(".item")];
          const position = items.findIndex((item) => item === this.el);
          this.pushEvent("set-list-position", {
            position,
            id: this.item_id(),
            type: this.item_type(),
          });
          this.el.style.setProperty("opacity", initialOpacity);
        },
        { once: true }
      );
      [...this.el.parentElement.querySelectorAll(".item")].forEach((el, i) => {
        el.addEventListener(
          "dragover",
          (e) => {
            const dragOffset =
              e.offsetY / el.getBoundingClientRect().height > 0.5;

            if (dragOffset) {
              el.before(this.el);
            } else {
              el.after(this.el);
            }
          },
          { signal: controller.signal }
        );
      });
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

window.addEventListener("phx:get-focus-projection-interpolation", (e) => {
  let renderer = document.getElementById("renderer");
  if (renderer) {
    renderer.getFocusProjectionInterpolation(e.detail.time);
  }
});
