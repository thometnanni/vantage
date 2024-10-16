import * as THREE from "three";

import center from "@turf/center";
import { GUI } from "three/addons/libs/lil-gui.module.min";
import { generateBuildings } from "./city";

import CameraOperator from "./cameraOperator";
import Projection from "./Projection";

import records from "./records";

// const geojsonUrl = "./nk-arcaden.json";
const geojsonUrl = "./hermannstrasse.json";
const imageUrl = "./media/warthe-helper.png";

let scene,
  renderer,
  buildings,
  ground,
  sky,
  cameraOperator,
  size = 10000,
  projections = [],
  activeProjection = 0;

init();

async function init() {
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0xcccccc);
  // scene.fog = new THREE.FogExp2(0xcccccc, 0.002);

  renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setAnimationLoop(update);

  document.body.appendChild(renderer.domElement);

  cameraOperator = new CameraOperator(renderer);

  const map = await fetch(geojsonUrl).then((d) => d.json());
  const mapCenter = center(map);

  const buildingGeometry = generateBuildings(map, mapCenter);

  const wireframeMaterial = new THREE.MeshPhongMaterial({
    color: 0xff0000,
  });

  const solidMaterial = new THREE.MeshPhongMaterial({
    color: 0xeeeeee,
  });

  const geo = new THREE.EdgesGeometry(buildingGeometry);
  const lineMaterial = new THREE.LineBasicMaterial({
    color: 0xff0000,
    linewidth: 5,
    linecap: "round",
    linejoin: "round",
  });

  const wireframe = new THREE.LineSegments(geo, lineMaterial);
  const solidMesh = new THREE.Mesh(buildingGeometry, solidMaterial);

  buildingGeometry.clearGroups();
  buildingGeometry.addGroup(0, Infinity, 0);
  buildingGeometry.addGroup(0, Infinity, 1);

  buildings = new THREE.Mesh(buildingGeometry, [
    wireframeMaterial,
    solidMaterial,
  ]);

  buildings.add(solidMesh);
  buildings.add(wireframe);

  buildings.name = "BUILDINGS";
  buildings.updateMatrix();
  buildings.layers.set(0);
  buildings.frustumCulled = false;
  // console.log(buildings);
  buildings.castShadow = true;

  scene.add(buildings);

  const groundGeometry = new THREE.BoxGeometry(size, size, 1);
  groundGeometry.rotateY(Math.PI);
  groundGeometry.rotateX(Math.PI / 2);
  groundGeometry.clearGroups();
  ground = new THREE.Mesh(groundGeometry, []);
  scene.add(ground);

  // DOME
  const skyGeometry = new THREE.PlaneGeometry(size, size, 2, 2);
  skyGeometry.rotateX(Math.PI / 2);
  skyGeometry.attributes.position.setX(0, -size / 4);
  skyGeometry.attributes.position.setZ(0, size / 4);
  skyGeometry.attributes.position.setX(2, size / 4);
  skyGeometry.attributes.position.setZ(2, size / 4);
  skyGeometry.attributes.position.setY(4, size);
  skyGeometry.attributes.position.setX(6, -size / 4);
  skyGeometry.attributes.position.setZ(6, -size / 4);
  skyGeometry.attributes.position.setX(8, size / 4);
  skyGeometry.attributes.position.setZ(8, -size / 4);
  skyGeometry.computeVertexNormals();
  skyGeometry.clearGroups();
  // skyGeometry.addGroup(0, Infinity, 0);
  sky = new THREE.Mesh(skyGeometry, []);
  scene.add(sky);

  const promises = records.map(async (record) => {
    const { position, rotation, fov, ratio } = record.camera;

    const loader = new THREE.TextureLoader();
    const texture = await new Promise((resolve) =>
      loader.load(
        record.media,
        (texture) => resolve(texture),
        undefined,
        (err) => console.error(err),
      ),
    );

    return { texture, record };
  });

  await Promise.all(promises).then((d) => {
    projections.push(
      ...d.map(({ record, texture }) => {
        const { position, rotation, fov, ratio, far, orthographic, size } =
          record.camera;
        return new Projection({
          renderer,
          scene,
          layers: { buildings, ground, sky },
          texture,
          cameraPosition: position,
          cameraRotation: rotation,
          fov,
          ratio,
          far,
          orthographic,
          size,
        });
      }),
    );
  });

  projections.forEach((projection) => {
    projection.update();
    scene.add(projection.helper);
  });

  // lights

  const dirLight1 = new THREE.DirectionalLight(0xffffff, 3);
  dirLight1.position.set(1, 1, 1);
  scene.add(dirLight1);

  const dirLight2 = new THREE.DirectionalLight(0xffffff, 3);
  dirLight2.position.set(-1, -1, -1);
  scene.add(dirLight2);

  const ambientLight = new THREE.AmbientLight(0xffffff, 0.8);
  scene.add(ambientLight);

  // HELPER

  // const helper = new THREE.CameraHelper(projections[0].camera);
  // helper.setColors(0xcccccc, 0xcccccc, 0xcccccc, 0xcccccc, 0xcccccc);
  // scene.add(helper);

  window.addEventListener("resize", onWindowResize);

  const options = {
    "toggle camera": cameraOperator.toggle,
  };

  const gui = new GUI();
  gui.add(options, "toggle camera");

  window.addEventListener("keydown", async ({ code, shiftKey }) => {
    const digit = /^Digit([0-9])/.exec(code)?.[1];
    if (digit != null) {
      const index = digit - 1;
      if (index >= projections.length) return;
      activeProjection = index;
      // projections.forEach((projection) => {
      //   projection.blur();
      // });

      // projections[activeProjection].focus();
      cameraOperator.detachProjection();
      cameraOperator.attachProjection(projections[activeProjection]);
    }
    if (code === "Space") {
      // cameraOperator.fp();
      if (cameraOperator.projection) {
        cameraOperator.detachProjection();
      } else {
        cameraOperator.attachProjection(
          projections[activeProjection],
          shiftKey,
        );
      }
    }

    if (code === "KeyC") {
      const currentRecords = records.map((r, i) => {
        const width = projections[i].camera.right - projections[i].camera.left;
        const height = projections[i].camera.top - projections[i].camera.bottom;
        return {
          ...r,
          camera: {
            position: [...projections[i].camera.position],
            rotation: [...projections[i].camera.rotation],
            fov: projections[i].camera.fov,
            ratio: projections[i].camera.aspect ?? height / width,
            far: projections[i].camera.far,
            size: width ?? undefined,
            orthographic: projections[i].camera.isOrthographicCamera,
          },
        };
      });

      await navigator.clipboard.writeText(
        JSON.stringify(currentRecords, null, 2),
      );
      console.log("copied to clipboard");
    }
  });
}

function onWindowResize() {
  cameraOperator.camera.aspect = window.innerWidth / window.innerHeight;
  cameraOperator.camera.updateProjectionMatrix();

  renderer.setSize(window.innerWidth, window.innerHeight);
}

function update() {
  renderer.render(scene, cameraOperator.camera);
}
