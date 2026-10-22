import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User, IUser } from '../models/User';
import { env } from '../config/env';
import { AppError } from '../middleware/errorHandler';
import { RegisterInput, LoginInput } from '../validators/auth.validator';

export interface SafeUser {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
  level: number;
  xp: number;
  currentStreak: number;
  longestStreak: number;
  createdAt: Date;
}

export interface AuthResponse {
  user: SafeUser;
  token: string;
}

export class AuthService {
  private static formatUser(user: IUser): SafeUser {
    return {
      id: user._id.toString(),
      email: user.email,
      name: user.name,
      avatarUrl: user.avatarUrl,
      level: user.level,
      xp: user.xp,
      currentStreak: user.currentStreak,
      longestStreak: user.longestStreak,
      createdAt: user.createdAt,
    };
  }

  private static generateToken(user: IUser): string {
    return jwt.sign(
      {
        sub: user._id.toString(),
        email: user.email,
      },
      env.JWT_SECRET,
      {
        expiresIn: '7d',
      }
    );
  }

  public static async register(input: RegisterInput): Promise<AuthResponse> {
    const normalizedEmail = input.email.toLowerCase().trim();

    // Check for existing account
    const existing = await User.findOne({ email: normalizedEmail });
    if (existing) {
      throw new AppError(
        'An account with this email address already exists',
        409,
        'DUPLICATE_EMAIL'
      );
    }

    // Hash password with bcrypt work factor 10
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(input.password, salt);

    // Create user record
    const user = await User.create({
      email: normalizedEmail,
      passwordHash,
      name: input.name.trim(),
      avatarUrl: input.avatarUrl,
    });

    const token = this.generateToken(user);

    return {
      user: this.formatUser(user),
      token,
    };
  }

  public static async login(input: LoginInput): Promise<AuthResponse> {
    const normalizedEmail = input.email.toLowerCase().trim();

    // Select passwordHash explicitly as it is select: false by default
    const user = await User.findOne({ email: normalizedEmail }).select(
      '+passwordHash'
    );

    if (!user) {
      throw new AppError(
        'Invalid email or password',
        401,
        'INVALID_CREDENTIALS'
      );
    }

    const isValidPassword = await user.comparePassword(input.password);
    if (!isValidPassword) {
      throw new AppError(
        'Invalid email or password',
        401,
        'INVALID_CREDENTIALS'
      );
    }

    const token = this.generateToken(user);

    return {
      user: this.formatUser(user),
      token,
    };
  }

  public static async getCurrentUser(userId: string): Promise<SafeUser> {
    const user = await User.findById(userId);
    if (!user) {
      throw new AppError('User profile not found', 404, 'USER_NOT_FOUND');
    }
    return this.formatUser(user);
  }
}
