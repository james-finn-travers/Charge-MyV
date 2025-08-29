# ChargeFinder

An EV charging station locator for Ontario, Canada. Find and filter over 2,000 charging stations across Ontario with detailed information about power levels, locations, and availability.

## Setup

1. Clone the repository
2. Install dependencies: `bundle install`
3. Setup database: `bin/rails db:create db:migrate`
4. Import charging station data: `ruby ontario_stations_importer.rb`
5. Start the server: `bin/dev`

## Features

- 🔍 Find nearby charging stations across Ontario
- ⚡ Filter by charging power (min/max kW)
- 📍 Location-based search with radius control
- 🗺️ Comprehensive coverage of Ontario charging infrastructure
- 🔐 User authentication and personalized experience
- 📱 Responsive design for mobile and desktop

## Data Sources

- OpenChargeMap API integration
- 2,000+ charging stations imported from multiple sources
- Real-time availability and station details

## Tech Stack

- Rails 8.0.2
- PostgreSQL
- Tailwind CSS
- Haversine distance calculations for location search
