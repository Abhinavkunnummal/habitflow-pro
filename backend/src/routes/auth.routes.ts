import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { validateRequest } from '../middleware/validate';
import { authenticate } from '../middleware/auth';
import { registerBodySchema, loginBodySchema } from '../validators/auth.validator';

const router = Router();

router.post('/register', validateRequest({ body: registerBodySchema }), AuthController.register);
router.post('/login', validateRequest({ body: loginBodySchema }), AuthController.login);
router.get('/me', authenticate, AuthController.me);

export default router;
