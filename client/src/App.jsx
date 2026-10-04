import React, { useState, useEffect } from 'react'

export default function App() {
  const [stations, setStations] = useState([])
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(false)

  const fetchStations = async (query = '') => {
    setLoading(true)
    try {
      const url = query ? `/api/v1/stations?location=${encodeURIComponent(query)}` : '/api/v1/stations'
      const res = await fetch(url)
      if (res.ok) {
        const data = await res.json()
        setStations(data)
      }
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchStations()
  }, [])

  const handleSearch = (e) => {
    e.preventDefault()
    fetchStations(search)
  }

  const handleCurrentLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(async (pos) => {
        setLoading(true)
        try {
          const res = await fetch(`/api/v1/stations?latitude=${pos.coords.latitude}&longitude=${pos.coords.longitude}`)
          if (res.ok) {
            const data = await res.json()
            setStations(data)
          }
        } catch (err) {
          console.error(err)
        } finally {
          setLoading(false)
        }
      })
    }
  }

  return (
    <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '2rem 1rem' }}>
      <header style={{ marginBottom: '2rem', textAlign: 'center' }}>
        <h1 style={{ fontSize: '2.5rem', fontWeight: 700, margin: 0 }}>⚡ Charge-MyV</h1>
        <p style={{ color: 'var(--text-secondary)' }}>Ontario EV Charging Station Locator</p>
      </header>

      <div className="glass-panel" style={{ padding: '1.5rem', marginBottom: '2rem' }}>
        <form onSubmit={handleSearch} style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
          <input
            type="text"
            placeholder="Search by city, address, or station name..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{
              flex: 1,
              minWidth: '240px',
              padding: '0.75rem 1rem',
              borderRadius: '8px',
              border: '1px solid var(--border-glass)',
              background: 'rgba(15, 23, 42, 0.6)',
              color: '#fff'
            }}
          />
          <button
            type="submit"
            style={{
              padding: '0.75rem 1.5rem',
              borderRadius: '8px',
              border: 'none',
              background: 'var(--accent)',
              color: '#fff',
              fontWeight: 600,
              cursor: 'pointer'
            }}
          >
            Search
          </button>
          <button
            type="button"
            onClick={handleCurrentLocation}
            style={{
              padding: '0.75rem 1.5rem',
              borderRadius: '8px',
              border: '1px solid var(--border-glass)',
              background: 'rgba(255, 255, 255, 0.1)',
              color: '#fff',
              cursor: 'pointer'
            }}
          >
            📍 My Location
          </button>
        </form>
      </div>

      <div>
        {loading ? (
          <p style={{ textAlign: 'center', color: 'var(--text-secondary)' }}>Loading stations...</p>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '1.5rem' }}>
            {stations.map((st) => (
              <div key={st.id} className="glass-panel" style={{ padding: '1.25rem' }}>
                <h3 style={{ margin: '0 0 0.5rem 0', fontSize: '1.2rem' }}>{st.name}</h3>
                <p style={{ margin: '0 0 0.5rem 0', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>{st.address}</p>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem' }}>
                  <span>⚡ {st.power_output ? `${st.power_output} kW` : 'Standard'}</span>
                  {st.distance && <span>📍 {st.distance} km</span>}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
