import React, { createContext, useReducer } from 'react';

const initialState = {
  incidents: [],
};

// Данные хранятся в памяти браузера
const IncidentContext = createContext();

const incidentReducer = (state, action) => {
  switch (action.type) {
    case 'SET_INCIDENTS':
      return { ...state, incidents: action.payload };
    case 'ADD_INCIDENT':
      return { ...state, incidents: [...state.incidents, action.payload] };
    case 'UPDATE_INCIDENT':
      return {
        ...state,
        incidents: state.incidents.map((item) =>
          item.id === action.payload.id ? action.payload : item
        ),
      };
    case 'DELETE_INCIDENT':
      return {
        ...state,
        incidents: state.incidents.filter((item) => item.id !== action.payload),
      };
    default:
      return state;
  }
};

export const IncidentProvider = ({ children }) => {
  const [state, dispatch] = useReducer(incidentReducer, initialState);

  return (
    <IncidentContext.Provider value={{ state, dispatch }}>
      {children}
    </IncidentContext.Provider>
  );
};

export default IncidentContext;