# ChargeFinder API Integration

This document explains how to import charging station data for all of Canada using the ChargeFinder API.

## 📊 Available Information

The ChargeFinder API provides comprehensive data for each charging station:

### **Basic Information**
- **Name**: Station name/identifier
- **Address**: Full address with street, city, province, postal code
- **Coordinates**: Latitude and longitude
- **Network**: Charging network (Tesla, Petro-Canada, etc.)

### **Technical Details**
- **Connector Types**: Type 1, Type 2, CCS, CHAdeMO, Tesla, etc.
- **Power Output**: Maximum charging speed in kW
- **Availability**: Operational status (available/unavailable/unknown)

### **Additional Details**
- **Pricing**: Cost per kWh or session fees
- **Operating Hours**: When the station is accessible
- **Amenities**: Nearby facilities (restaurants, shopping, etc.)

## 🚀 Getting Started

### 1. Get API Key
- Visit [ChargeFinder Developers](https://chargefinder.com/developers)
- Sign up for an API key
- Note your API key for the next steps

### 2. Set Environment Variable
```bash
# Add to your .env file or export directly
export CHARGEFINDER_API_KEY="your_api_key_here"
```

### 3. Run Database Migration
```bash
rails db:migrate
```

## 📥 Running the Import

### Import All of Canada
```bash
rails charging_stations:import_canada
```

### Import Specific Province
```bash
# Ontario
rails charging_stations:import_province[ON]

# British Columbia
rails charging_stations:import_province[BC]

# Quebec
rails charging_stations:import_province[QC]
```

### Available Province Codes
- **AB**: Alberta
- **BC**: British Columbia
- **MB**: Manitoba
- **NB**: New Brunswick
- **NL**: Newfoundland and Labrador
- **NS**: Nova Scotia
- **NT**: Northwest Territories
- **NU**: Nunavut
- **ON**: Ontario
- **PE**: Prince Edward Island
- **QC**: Quebec
- **SK**: Saskatchewan
- **YT**: Yukon

## 🔧 Customization

### Modify Import Logic
Edit `app/services/chargefinder_importer.rb` to:
- Change API endpoints
- Modify data mapping
- Adjust rate limiting
- Add error handling

### Add New Fields
If you want to capture additional data:
1. Add columns to the database
2. Update the `create_or_update_station` method
3. Modify the data extraction methods

## ⚠️ Important Notes

### Rate Limiting
- The importer includes 1-second delays between provinces
- Respect API rate limits to avoid being blocked
- Consider running imports during off-peak hours

### Data Quality
- Some stations may have incomplete information
- The importer handles missing data gracefully
- Duplicate stations are prevented using external_id

### API Changes
- ChargeFinder may update their API structure
- Monitor for breaking changes
- Update the importer accordingly

## 🐛 Troubleshooting

### Common Issues

**API Key Error**
```
ERROR: Please set CHARGEFINDER_API_KEY environment variable
```
Solution: Set your API key as an environment variable

**Network Errors**
```
Error importing ON: Connection timeout
```
Solution: Check your internet connection and try again

**Database Errors**
```
Error saving station: Validation failed
```
Solution: Check the migration ran successfully

### Getting Help
- Check the Rails logs for detailed error messages
- Verify your API key is valid
- Ensure the database migration completed
- Test with a single province first

## 📈 Performance Tips

- Start with a single province to test
- Monitor API response times
- Consider running imports in the background
- Use database indexes for better query performance 