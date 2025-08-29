Geocoder.configure(
  # Geocoding options
  timeout: 10,                # geocoding service timeout (secs)
  lookup: :nominatim,         # Use free OpenStreetMap Nominatim service
  ip_lookup: :ipinfo_io,      # IP address geocoding service (optional)
  language: :en,              # ISO-639 language code
  use_https: true,           # use HTTPS for lookup requests? (if supported)
  http_proxy: nil,           # HTTP proxy server (user:pass@host:port)
  https_proxy: nil,          # HTTPS proxy server (user:pass@host:port)
  api_key: nil,              # API key for geocoding service
  cache: nil,                # Disable cache temporarily for testing
  cache_prefix: 'geocoder:', # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  always_raise: [Timeout::Error, SocketError],

  # Calculation options
  units: :km,                # :km for kilometers or :mi for miles
  distances: :linear,        # :spherical or :linear
  
  # Nominatim specific options
  nominatim: {
    host: "nominatim.openstreetmap.org",
    user_agent: "ChargeFinder/1.0 (contact@chargefinder.app)"
  }
)
