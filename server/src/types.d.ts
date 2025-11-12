/// <reference types="express" />
/// <reference types="mongoose" />
/// <reference types="cors" />
/// <reference types="nodemailer" />

import { Request } from 'express';
import { Document } from 'mongoose';

interface UserDocument extends Document {
  _id: string;
  name: string;
  email: string;
  isAdmin: boolean;
}

declare global {
  namespace Express {
    interface Request {
      user?: UserDocument;
    }
  }
}
