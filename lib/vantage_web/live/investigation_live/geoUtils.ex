defmodule VantageWeb.GeoUtils do
  # Earth's radius in meters
  @r 6_371_008.8

  def rhumb_distance([lon1, lat1], [lon2, lat2]) do
    # Adjust longitude for wraparound
    lon2 =
      cond do
        lon2 - lon1 > 180 -> lon2 - 360
        lon1 - lon2 > 180 -> lon2 + 360
        true -> lon2
      end

    # Convert to radians
    phi1 = lat1 * :math.pi() / 180
    phi2 = lat2 * :math.pi() / 180
    delta_phi = phi2 - phi1

    delta_lambda = abs(lon2 - lon1) * :math.pi() / 180
    # Adjust if greater than PI
    delta_lambda =
      if delta_lambda > :math.pi(), do: delta_lambda - 2 * :math.pi(), else: delta_lambda

    # Calculate delta psi (difference in meridional parts)
    delta_psi =
      :math.log(:math.tan(phi2 / 2 + :math.pi() / 4) / :math.tan(phi1 / 2 + :math.pi() / 4))

    # Calculate q (ratio of distances)
    q = if abs(delta_psi) > 1.0e-11, do: delta_phi / delta_psi, else: :math.cos(phi1)

    # Calculate distance
    delta = :math.sqrt(delta_phi * delta_phi + q * q * delta_lambda * delta_lambda)

    # Return distance in meters
    delta * @r
  end

  def radians_to_degrees(radians) do
    normalized_radians = radians - 2 * :math.pi() * Float.floor(radians / (2 * :math.pi()))
    normalized_radians * 180 / :math.pi()
  end

  def degrees_to_radians(degrees) do
    normalized_degrees = degrees - 360 * Float.floor(degrees / 360)
    normalized_degrees * :math.pi() / 180
  end

  def rhumb_bearing([from_lon, from_lat], [to_lon, to_lat]) do
    phi1 = degrees_to_radians(from_lat)
    phi2 = degrees_to_radians(to_lat)
    delta_lambda = degrees_to_radians(to_lon - from_lon)

    # Normalize delta_lambda to be between -π and π
    delta_lambda =
      cond do
        delta_lambda > :math.pi() -> delta_lambda - 2 * :math.pi()
        delta_lambda < -:math.pi() -> delta_lambda + 2 * :math.pi()
        true -> delta_lambda
      end

    delta_psi =
      :math.log(:math.tan(phi2 / 2 + :math.pi() / 4) / :math.tan(phi1 / 2 + :math.pi() / 4))

    theta = :math.atan2(delta_lambda, delta_psi)

    # Convert to degrees and normalize
    bear360 =
      radians_to_degrees(theta) + 360 - 360 * Float.floor((radians_to_degrees(theta) + 360) / 360)

    if bear360 > 180, do: -(360 - bear360), else: bear360
  end

  def coords_to_meters([x, y], [lon, lat]) do
    distance =
      rhumb_distance(
        [
          x,
          y
        ],
        [lon, lat]
      )

    bearing =
      rhumb_bearing(
        [x, y],
        [lon, lat]
      ) * :math.pi() / 180

    x = distance * :math.cos(bearing) * -1
    y = distance * :math.sin(bearing)

    {x, y}
  end

  def meters_to_coords([x, y], [lon, lat]) do
    # Convert x,y to distance and bearing
    distance = :math.sqrt(x * x + y * y)
    # Adjust bearing calculation to match coords_to_meters
    bearing = :math.atan2(y, -x) * 180 / :math.pi()

    # Convert to radians
    lat1 = degrees_to_radians(lat)
    lon1 = degrees_to_radians(lon)
    theta = degrees_to_radians(bearing)

    # Calculate angular distance
    delta = distance / @r

    # Calculate destination point
    lat2 =
      :math.asin(
        :math.sin(lat1) * :math.cos(delta) +
          :math.cos(lat1) * :math.sin(delta) * :math.cos(theta)
      )

    d_lon =
      :math.atan2(
        :math.sin(theta) * :math.sin(delta) * :math.cos(lat1),
        :math.cos(delta) - :math.sin(lat1) * :math.sin(lat2)
      )

    lon2 =
      (lon1 + d_lon + :math.pi())
      |> :math.fmod(2 * :math.pi())
      |> Kernel.-(:math.pi())

    # Convert back to degrees
    {radians_to_degrees(lon2), radians_to_degrees(lat2)}
  end

  def meters_to_coords_alt([x, y], [lon, lat]) do
    # Convert x,y to distance and bearing
    distance = :math.sqrt(x * x + y * y)
    bearing = normalize_bearing(:math.atan2(y, -x) * 180 / :math.pi())

    # Convert to radians
    lat1 = degrees_to_radians(lat)
    lon1 = degrees_to_radians(lon)
    brng = degrees_to_radians(bearing)

    # Calculate angular distance
    delta = distance / @r

    # Calculate destination point using haversine formula
    lat2 =
      :math.asin(
        :math.sin(lat1) * :math.cos(delta) +
          :math.cos(lat1) * :math.sin(delta) * :math.cos(brng)
      )

    lon2 =
      lon1 +
        :math.atan2(
          :math.sin(brng) * :math.sin(delta) * :math.cos(lat1),
          :math.cos(delta) - :math.sin(lat1) * :math.sin(lat2)
        )

    # Normalize longitude to -180 to +180
    lon2 = normalize_longitude(radians_to_degrees(lon2))
    lat2 = radians_to_degrees(lat2)

    {lon2, lat2}
  end

  # Add these helper functions
  defp normalize_bearing(bearing) do
    bearing = bearing + 360
    bearing - 360 * Float.floor(bearing / 360)
  end

  defp normalize_longitude(lon) do
    cond do
      lon > 180 -> lon - 360
      lon < -180 -> lon + 360
      true -> lon
    end
  end

  def meters_to_coords_alt_2([x, y], [lon, lat]) do
    # Convert x,y to distance and bearing
    distance = :math.sqrt(x * x + y * y)
    bearing = :math.atan2(y, -x) * 180 / :math.pi()

    # Convert to radians
    lat1 = degrees_to_radians(lat)
    lon1 = degrees_to_radians(lon)
    theta = degrees_to_radians(bearing)

    # Calculate angular distance
    delta = distance / @r

    # Calculate the meridional parts for lat1
    mp1 = :math.log(:math.tan(lat1 / 2 + :math.pi() / 4))

    # Calculate destination latitude using rhumb line formula
    lat2 = lat1 + delta * :math.cos(theta)

    # Calculate the meridional parts for lat2
    mp2 = :math.log(:math.tan(lat2 / 2 + :math.pi() / 4))

    # Calculate the change in longitude
    delta_psi = mp2 - mp1
    delta_lon = delta * :math.sin(theta) / :math.cos(lat1)

    # Calculate final longitude
    lon2 = lon1 + delta_lon

    # Convert back to degrees and normalize
    lon2_deg = radians_to_degrees(lon2)
    lat2_deg = radians_to_degrees(lat2)

    # Normalize longitude to -180 to +180
    lon2_deg =
      cond do
        lon2_deg > 180 -> lon2_deg - 360
        lon2_deg < -180 -> lon2_deg + 360
        true -> lon2_deg
      end

    {lon2_deg, lat2_deg}
  end
end
