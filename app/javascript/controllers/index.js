// Import and register all your controllers from the esbuild via controllers/**/*_controller
import { application } from "./application"
eagerLoadControllersFrom("controllers", application)
