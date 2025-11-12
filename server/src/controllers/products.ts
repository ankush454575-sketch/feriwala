import { Request, Response } from 'express';
import Product from '../models/Product';
import asyncHandler from '../utils/asyncHandler';
import ApiError from '../utils/ApiError';

// @desc    Get all products
// @route   GET /api/products
// @access  Public
export const getProducts = asyncHandler(async (req: Request, res: Response) => {
  const products = await Product.find({});
  res.json(products);
});

// @desc    Get single product
// @route   GET /api/products/:id
// @access  Public
export const getProductById = asyncHandler(async (req: Request, res: Response) => {
  const product = await Product.findById(req.params.id);

  if (product) {
    res.json(product);
  } else {
    throw new ApiError(404, 'Product not found');
  }
});

// @desc    Create a product
// @route   POST /api/products
// @access  Private/Admin
export const createProduct = asyncHandler(async (req: Request, res: Response) => {
  // Assuming user is authenticated and isAdmin check is done in middleware
  const { name, description, price, image } = req.body;

  const product = new Product({
    name,
    description,
    price,
    image,
    rating: 0, // New products start with 0 rating
  });

  const createdProduct = await product.save();
  res.status(201).json(createdProduct);
});

// @desc    Update a product
// @route   PUT /api/products/:id
// @access  Private/Admin
export const updateProduct = asyncHandler(async (req: Request, res: Response) => {
  // Assuming user is authenticated and isAdmin check is done in middleware
  const { name, description, price, image, rating } = req.body;

  const product = await Product.findById(req.params.id);

  if (product) {
    product.name = name || product.name;
    product.description = description || product.description;
    product.price = price || product.price;
    product.image = image || product.image;
    product.rating = rating || product.rating;

    const updatedProduct = await product.save();
    res.json(updatedProduct);
  } else {
    throw new ApiError(404, 'Product not found');
  }
});

// @desc    Delete a product
// @route   DELETE /api/products/:id
// @access  Private/Admin
export const deleteProduct = asyncHandler(async (req: Request, res: Response) => {
  // Assuming user is authenticated and isAdmin check is done in middleware
  const product = await Product.findById(req.params.id);

  if (product) {
    await product.deleteOne();
    res.json({ message: 'Product removed' });
  } else {
    throw new ApiError(404, 'Product not found');
  }
});