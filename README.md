<img width="1492" alt="Screenshot 2025-03-01 at 18 51 32" src="https://github.com/user-attachments/assets/8eef75a0-25ea-4dab-816d-646bfd30d184" />

## About

**Vantage** is an open-source tool designed for **fact-checkers, investigative journalists, and Open Source Intelligence (OSINT) practitioners**. It enables users to **reconstruct spatial contexts of images and videos** by projecting them onto **3D environments**.

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

3. Build and start the container:

```code
docker compose up
```

3. Access the platform at: [http://localhost:4000](http://localhost:4000) .

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
2. Import the model into Vantage.
3. Align images and videos by matching their perspectives with real-world camera positions.
4. Use the timeline to organize and analyze events as they unfold.

