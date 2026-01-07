import rateLimit from "express-rate-limit";

export const forgotPasswordLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 phút
  max: 5, // tối đa 5 request
  message: {
    message: "Quá nhiều yêu cầu, vui lòng thử lại sau",
  },
});
