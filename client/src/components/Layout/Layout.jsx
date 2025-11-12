import React from 'react';
import { Outlet } from 'react-router-dom';
import Navbar from '../Navbar/Navbar';
import Footer from '../Footer/Footer';
import { Container } from '@mui/material';

const Layout = () => {
  return (
    <>
      <Navbar cartCount={0} />
      <Container component="main" sx={{ mt: 4, mb: 4 }}>
        <Outlet />
      </Container>
      <Footer />
    </>
  );
};

export default Layout;
