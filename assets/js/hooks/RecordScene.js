import { zipSync } from "fflate";
export default {
  max_time() {
    return +this.el.dataset.maxTime;
  },
  mounted() {
    this.el.addEventListener("click", () => {
      const vantageRenderer = document.getElementById("renderer");

      const focusProjection = Object.values(renderer.projections).find(
        (projection) => projection.focus
      );
      // renderer.exportImageSequence(10, 30, 1920, 1080, focus?.camera)
      const duration = this.max_time();

      let width = 1920;
      let height = 1080;

      if (focusProjection) {
        focusProjection.focus = false;

        width =
          focusProjection.texture.source.data.videoWidth ??
          focusProjection.texture.source.data.width;

        height =
          focusProjection.texture.source.data.videoHeight ??
          focusProjection.texture.source.data.height;
      }

      exportImageSequence(
        vantageRenderer,
        duration,
        25,
        width,
        height,
        focusProjection?.camera
      ).then(() => {
        focusProjection.focus = true;
      });
    });
  },
};

async function exportImageSequence(
  vantageRenderer,
  durationSeconds = 3,
  fps = 30,
  width,
  height,
  camera
) {
  const rendererSize = (() => {
    const rect = vantageRenderer.getBoundingClientRect();
    return [rect.width, rect.height];
  })();

  const rendererPixelRatio = vantageRenderer.renderer.getPixelRatio();
  if (width && height) {
    vantageRenderer.renderer.setSize(width, height, false);
    vantageRenderer.renderer.setPixelRatio(1);
  }

  const totalFrames = durationSeconds * fps;
  vantageRenderer.renderer.setAnimationLoop(null);

  const batchSize = 250;
  let files = {};
  let batchIndex = 0;

  let percentage = "0";

  for (let i = 0; i < totalFrames; i++) {
    if (((i / totalFrames) * 100).toFixed(0) != percentage) {
      percentage = ((i / totalFrames) * 100).toFixed(0);
      console.log(`${percentage}%`);
    }

    const t = i / fps;
    vantageRenderer.setAttribute("time", t);
    Object.values(vantageRenderer.projections).forEach(({ element }) => {
      element.updateTime(t);
    });

    vantageRenderer.update();

    await new Promise((resolve) => setTimeout(resolve, 100));
    vantageRenderer.renderer.render(
      vantageRenderer.scene,
      camera ?? vantageRenderer.cameraOperator.camera
    );

    const dataUrl = vantageRenderer.renderer.domElement.toDataURL("image/png");
    const base64 = dataUrl.split(",")[1];
    const binary = Uint8Array.from(atob(base64), (c) => c.charCodeAt(0));
    files[`frame_${`${i}`.padStart(4, "0")}.png`] = binary;

    // When batch is full or last frame, zip and download
    if ((i + 1) % batchSize === 0 || i === totalFrames - 1) {
      const zipped = zipSync(files);
      const blob = new Blob([zipped], { type: "application/zip" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `sequence_batch_${batchIndex + 1}.zip`;
      document.body.appendChild(a);
      a.click();
      setTimeout(() => {
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      }, 100);
      files = {};
      batchIndex++;
    }
  }

  vantageRenderer.renderer.setAnimationLoop(vantageRenderer.update);

  if (width && height) {
    vantageRenderer.renderer.setSize(...rendererSize, false);
    vantageRenderer.renderer.setPixelRatio(rendererPixelRatio);
  }
}
