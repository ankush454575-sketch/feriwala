import React from 'react';
import { Container, Typography, Link } from '@mui/material';

const Footer = () => {
  return (
    <Container
      maxWidth="lg"
      component="footer"
      sx={{
        borderTop: (theme) => `1px solid ${theme.palette.divider}`,
        mt: 8,
        py: [3, 6],
      }}
    >
      <Typography variant="body2" color="text.secondary" align="center">
        {'© '}
        <Link color="inherit" href="#">
          Feriwala
        </Link>{' '}
        {new Date().getFullYear()}
        {'.'}
      </Typography>
      <Typography variant="body2" color="text.secondary" align="center" sx={{ mt: 1 }}>
        <Link href="#facebook" color="inherit" sx={{ mx: 1 }}>
          Facebook
        </Link>
        |
        <Link href="#twitter" color="inherit" sx={{ mx: 1 }}>
          Twitter
        </Link>
        |
        <Link href="#instagram" color="inherit" sx={{ mx: 1 }}>
          Instagram
        </Link>
      </Typography>
    </Container>
  );
};

export default Footer;
