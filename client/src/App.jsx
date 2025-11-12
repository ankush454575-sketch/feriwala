import { useState } from 'react'
import './App.css'

function App() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [cartCount, setCartCount] = useState(0)

  const products = [
    { id: 1, name: 'Wireless Headphones', price: '$49.99', rating: 4.5, image: '🎧' },
    { id: 2, name: 'Smart Watch', price: '$199.99', rating: 4.8, image: '⌚' },
    { id: 3, name: 'Phone Case', price: '$19.99', rating: 4.2, image: '📱' },
    { id: 4, name: 'USB-C Cable', price: '$9.99', rating: 4.7, image: '🔌' },
    { id: 5, name: 'Screen Protector', price: '$14.99', rating: 4.4, image: '🛡️' },
    { id: 6, name: 'Power Bank', price: '$29.99', rating: 4.6, image: '🔋' },
  ]

  const addToCart = (productName) => {
    setCartCount(cartCount + 1)
    alert(`${productName} added to cart!`)
  }

  return (
    <div className="app">
      {/* Navigation */}
      <nav className="navbar">
        <div className="nav-container">
          <div className="logo">
            <h2>🛍️ Feriwala</h2>
            <p className="tagline">Your Online Store</p>
          </div>
          
          <button 
            className="menu-toggle"
            onClick={() => setIsMenuOpen(!isMenuOpen)}
          >
            ☰
          </button>

          <ul className={`nav-menu ${isMenuOpen ? 'active' : ''}`}>
            <li><a href="#home">Home</a></li>
            <li><a href="#products">Products</a></li>
            <li><a href="#about">About</a></li>
            <li><a href="#contact">Contact</a></li>
          </ul>

          <div className="cart-icon">
            🛒 <span className="cart-badge">{cartCount}</span>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="hero">
        <div className="hero-content">
          <h1>Welcome to Feriwala</h1>
          <p>Discover amazing products at unbeatable prices</p>
          <button className="cta-button">Shop Now</button>
        </div>
      </section>

      {/* Products Section */}
      <section className="products" id="products">
        <h2>Featured Products</h2>
        <div className="products-grid">
          {products.map((product) => (
            <div key={product.id} className="product-card">
              <div className="product-image">{product.image}</div>
              <h3>{product.name}</h3>
              <p className="price">{product.price}</p>
              <p className="rating">⭐ {product.rating}</p>
              <button 
                className="add-to-cart-btn"
                onClick={() => addToCart(product.name)}
              >
                Add to Cart
              </button>
            </div>
          ))}
        </div>
      </section>

      {/* Features Section */}
      <section className="features">
        <h2>Why Choose Feriwala?</h2>
        <div className="features-grid">
          <div className="feature">
            <div className="feature-icon">🚚</div>
            <h3>Fast Shipping</h3>
            <p>Delivery to your doorstep in 2-5 business days</p>
          </div>
          <div className="feature">
            <div className="feature-icon">💰</div>
            <h3>Great Prices</h3>
            <p>Competitive pricing with regular discounts</p>
          </div>
          <div className="feature">
            <div className="feature-icon">🛡️</div>
            <h3>Secure Payment</h3>
            <p>Your transactions are 100% secure and encrypted</p>
          </div>
          <div className="feature">
            <div className="feature-icon">💬</div>
            <h3>24/7 Support</h3>
            <p>Our support team is always here to help</p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <p>&copy; 2025 Feriwala. All rights reserved.</p>
        <div className="social-links">
          <a href="#facebook">Facebook</a> | 
          <a href="#twitter">Twitter</a> | 
          <a href="#instagram">Instagram</a>
        </div>
      </footer>
    </div>
  )
}

export default App
