import React, { useState } from 'react';
import './App.css';

function App() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [cartCount, setCartCount] = useState(0);

  const products = [
    { id: 1, name: 'Wireless Headphones', price: '$49.99', rating: 4.5, image: '🎧' },
    { id: 2, name: 'Smart Watch', price: '$199.99', rating: 4.8, image: '⌚' },
    { id: 3, name: 'Phone Case', price: '$19.99', rating: 4.2, image: '📱' },
    { id: 4, name: 'USB-C Cable', price: '$9.99', rating: 4.7, image: '🔌' },
    { id: 5, name: 'Screen Protector', price: '$14.99', rating: 4.4, image: '🛡️' },
    { id: 6, name: 'Power Bank', price: '$29.99', rating: 4.6, image: '🔋' },
  ];

  const features = [
    { icon: '🚚', title: 'Fast Shipping', description: 'Delivery to your doorstep in 2-5 business days' },
    { icon: '💰', title: 'Great Prices', description: 'Competitive pricing with regular discounts' },
    { icon: '🛡️', title: 'Secure Payment', description: 'Your transactions are 100% secure and encrypted' },
    { icon: '💬', title: '24/7 Support', description: 'Our support team is always here to help' },
  ];

  const addToCart = (productName) => {
    setCartCount(cartCount + 1);
    alert(`✓ ${productName} added to cart!`);
  };

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  const handleMenuItemClick = (item) => {
    console.log(`Navigating to: ${item}`);
    setIsMenuOpen(false);
  };

  return (
    <div className="app" role="application" aria-label="Feriwala E-commerce Application">
      {/* Skip to main content link for accessibility */}
      <a href="#main-content" className="skip-to-main" role="navigation">
        Skip to main content
      </a>

      {/* Navigation */}
      <nav className="navbar" role="navigation" aria-label="Main navigation">
        <div className="nav-container">
          <div className="logo">
            <h1 style={{ fontSize: '1.5rem', margin: 0 }}>
              <span aria-label="Feriwala">🛍️ Feriwala</span>
            </h1>
            <p className="tagline">Your Online Store</p>
          </div>

          <button
            className="menu-toggle"
            onClick={toggleMenu}
            aria-expanded={isMenuOpen}
            aria-controls="nav-menu"
            aria-label="Toggle navigation menu"
          >
            ☰
          </button>

          <ul
            className={`nav-menu ${isMenuOpen ? 'active' : ''}`}
            id="nav-menu"
            role="menubar"
            aria-label="Navigation menu"
          >
            <li role="none">
              <a href="#home" role="menuitem" onClick={() => handleMenuItemClick('home')}>
                Home
              </a>
            </li>
            <li role="none">
              <a href="#products" role="menuitem" onClick={() => handleMenuItemClick('products')}>
                Products
              </a>
            </li>
            <li role="none">
              <a href="#features" role="menuitem" onClick={() => handleMenuItemClick('features')}>
                Features
              </a>
            </li>
            <li role="none">
              <a href="#contact" role="menuitem" onClick={() => handleMenuItemClick('contact')}>
                Contact
              </a>
            </li>
          </ul>

          <div
            className="cart-icon"
            role="button"
            tabIndex={0}
            aria-label={`Shopping cart with ${cartCount} items`}
            onClick={() => console.log('Cart clicked')}
            onKeyDown={(e) => e.key === 'Enter' && console.log('Cart clicked')}
          >
            🛒 <span className="cart-badge" aria-live="polite">{cartCount}</span>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="hero" id="home" role="region" aria-label="Hero section">
        <div className="hero-content">
          <h2>Welcome to Feriwala</h2>
          <p>Discover amazing products at unbeatable prices</p>
          <button className="cta-button" aria-label="Start shopping for products">
            Shop Now
          </button>
        </div>
      </section>

      {/* Main Content */}
      <main id="main-content">
        {/* Products Section */}
        <section className="products" id="products" role="region" aria-label="Featured products">
          <h2>Featured Products</h2>
          <div className="products-grid" role="list" aria-label="List of featured products">
            {products.map((product) => (
              <article
                key={product.id}
                className="product-card"
                role="listitem"
                aria-label={`${product.name}, ${product.price}`}
              >
                <div className="product-image" role="img" aria-label={product.name}>
                  {product.image}
                </div>
                <h3>{product.name}</h3>
                <p className="price" aria-label={`Price: ${product.price}`}>
                  {product.price}
                </p>
                <p className="rating" aria-label={`Rating: ${product.rating} out of 5 stars`}>
                  ⭐ {product.rating}
                </p>
                <button
                  className="add-to-cart-btn"
                  onClick={() => addToCart(product.name)}
                  aria-label={`Add ${product.name} to shopping cart`}
                >
                  Add to Cart
                </button>
              </article>
            ))}
          </div>
        </section>

        {/* Features Section */}
        <section className="features" id="features" role="region" aria-label="Why choose Feriwala">
          <h2>Why Choose Feriwala?</h2>
          <div className="features-grid" role="list" aria-label="List of features">
            {features.map((feature, index) => (
              <article
                key={index}
                className="feature"
                role="listitem"
                aria-label={feature.title}
              >
                <div
                  className="feature-icon"
                  role="img"
                  aria-label={feature.title}
                >
                  {feature.icon}
                </div>
                <h3>{feature.title}</h3>
                <p>{feature.description}</p>
              </article>
            ))}
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="footer" role="contentinfo">
        <p>&copy; 2025 Feriwala. All rights reserved.</p>
        <div className="social-links" role="navigation" aria-label="Social media links">
          <a href="#facebook" aria-label="Feriwala on Facebook">
            Facebook
          </a>
          {' | '}
          <a href="#twitter" aria-label="Feriwala on Twitter">
            Twitter
          </a>
          {' | '}
          <a href="#instagram" aria-label="Feriwala on Instagram">
            Instagram
          </a>
        </div>
      </footer>
    </div>
  );
}

export default App;
