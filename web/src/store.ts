import { configureStore } from '@reduxjs/toolkit'
import localeSlice from './slices/localeSlice'

export const store = configureStore({
  reducer: {
    localeSlice
  },
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch