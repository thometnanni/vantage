<p align="center">
  <img align="center" src="https://github.com/user-attachments/assets/e15fa811-4d75-4658-9a2c-7618c05b9abf" height="150" alt="Vantage">
  <br>
    <p align="center">
    An open-source tool designed for fact-checkers, investigative journalists, and Open Source Intelligence (OSINT) practitioners. It enables users to reconstruct spatial contexts of images and videos by projecting them onto 3D environments.
    <br>
  </p>
  <p align="center"><a href="https://vantage.thometnanni.net/">Platform Overview</a> &bull; <a href="https://github.com/thometnanni/vantage/?tab=readme-ov-file#installation-docker">Installation</a></p>
</p>

---

<br>
<br>

<img width="49%" alt="Screenshot 2025-04-11 at 10 12 53" src="https://github.com/user-attachments/assets/7bb91296-b8eb-4df9-8316-930e99a37a2c" />
<img width="49%" alt="Screenshot 2025-04-11 at 10 13 47" src="https://github.com/user-attachments/assets/2fe26a90-1a47-49c5-8c63-3b3ff7e89f8b" />

## License

Vantage is open source, licensed under the MIT License.

## Installation (Docker)

### Prerequisites

- Install and run [Docker Desktop](https://www.docker.com/products/docker-desktop) if you haven't already.


### Steps

1. Clone the repository:

```code
git clone https://github.com/thometnanni/vantage.git
cd vantage
```

2. Rename the `.env.example` file to `.env`
```code
mv .env.example .env
```

3. Build and start the container:

```code
docker compose up
```

4. Access the platform at: [http://localhost:4000](http://localhost:4000) .

## Installation (Mix)

If you prefer to run Vantage directly using Mix (suitable for development):

### Prerequisites

Ensure you have the following installed:

- **Elixir:** [Download Elixir](https://elixir-lang.org/install.html)
- **Node.js:** [Download Node.js](https://nodejs.org/)
- **npm:** [Download npm](https://www.npmjs.com/get-npm)
- **ffmpeg:** [Download ffmpeg](https://ffmpeg.org/download.html)

### Steps

1. Clone the repository:

```code
git clone https://github.com/thometnanni/vantage.git cd vantage
```

2. Setup dependencies:

```code
cd assets
npm install
cd ..
```


```code
mix setup
```

3. Start the server

```code
mix phx.server
```

or with IEx:


```code
iex -S mix phx.server
```

4. Access the platform at: [http://localhost:4000](http://localhost:4000) .

## 3D Scene Setup

To generate a 3D model and map of a given location, use the Vantage [Scene Setup](https://thometnanni.github.io/vantage-scene-setup/) tool.

This lets you select a coordinate, generate a 3D model, and then import it into Vantage.
Alternatevely, you can import any glTF file.

## Usage

To reconstruct a scene:

1. Generate a 3D scene using the Vantage Scene Setup tool.
2. Import the model and map into Vantage.
3. Align images and videos by matching their perspectives with real-world camera positions.
   - Use the first-person view to position media:
     - **W**: Move forward
     - **A**: Move left
     - **S**: Move backward
     - **D**: Move right
     - **F**: Move down
     - **R**: Move up
     - **Q**: Rotate camera counterclockwise (around Z-axis)
     - **E**: Rotate camera clockwise (around Z-axis)
4. Use the mouse wheel to adjust the camera's field of view (FOV) for zooming in or out.
5. Use the timeline to organize and analyze events as they unfold.
