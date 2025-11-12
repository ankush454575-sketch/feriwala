import React from 'react';
import { Button, Container, Grid, Typography } from '@mui/material';

const products = [
  { id: 1, name: 'Wireless Headphones', price: '$49.99', rating: 4.5, image: '🎧' },
  { id: 2, name: 'Smart Watch', price: '$199.99', rating: 4.8, image: '⌚' },
  { id: 3, name: 'Phone Case', price: '$19.99', rating: 4.2, image: '📱' },
  { id: 4, name: 'USB-C Cable', price: '$9.99', rating: 4.7, image: '🔌' },
  { id: 5, name: 'Screen Protector', price: '$14.99', rating: 4.4, image: '🛡️' },
  { id: 6, name: 'Power Bank', price: '$29.99', rating: 4.6, image: '🔋' },
];

const Home = () => {
  const addToCart = (productName) => {
    alert(`${productName} added to cart!`);
  };

  return (
    <>
      {/* Hero Section */}
      <Container sx={{ mt: 4 }}>
        <Typography variant="h2" component="h1" gutterBottom>
          Welcome to Feriwala
        </Typography>
        <Typography variant="h5" component="p" color="text.secondary" sx={{ mb: 4 }}>
          Discover amazing products at unbeatable prices
        </Typography>
        <Button variant="contained" size="large">
          Shop Now
        </Button>
      </Container>

      {/* Products Section */}
      <Container sx={{ mt: 8 }}>
        <Typography variant="h4" component="h2" gutterBottom>
          Featured Products
        </Typography>
        <Grid container spacing={4}>
          {products.map((product) => (
            <Grid item key={product.id} xs={12} sm={6} md={4}>
              <div className="product-card">
                <div className="product-image">{product.image}</div>
                <h3>{product.name}</h3>
                <p className="price">{product.price}</p>
                <p className="rating">⭐ {product.rating}</p>
                <Button
                  variant="outlined"
                  onClick={() => addToCart(product.name)}
                >
                  Add to Cart
                </Button>
              </div>
            </Grid>
          ))}
        </Grid>
      </Container>

      {/* Features Section */}
      <Container sx={{ mt: 8 }}>
        <Typography variant="h4" component="h2" gutterBottom>
          Why Choose Feriwala?
        </Typography>
        <Grid container spacing={4}>
          <Grid item xs={12} sm={6} md={3}>
            <div className="feature">
              <div className="feature-icon">🚚</div>
              <h3>Fast Shipping</h3>
              <p>Delivery to your doorstep in 2-5 business days</p>
            </div>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <div className="feature">
              <div className="feature-icon">💰</div>
              <h3>Great Prices</h3>
              <p>Competitive pricing with regular discounts</p>
            </div>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <div className="feature">
              <div className="feature-icon">🛡️</div>
              <h3>Secure Payment</h3>
              <p>Your transactions are 100% secure and encrypted</p>
            </div>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <div className="feature">
              <div className="feature-icon">💬</div>
              <h3>24/7 Support</h3>
              <p>Our support team is always here to help</p>
            </div>
          </Grid>
        </Grid>
      </Container>
    </>
  );
};

export default Home;
