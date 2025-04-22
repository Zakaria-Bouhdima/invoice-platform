import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || '/api';

export const fetchRules = async (clientId) => {
  const response = await axios.get(`${API_BASE_URL}/rules`, {
    headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
    params: { clientId },
  });
  return response.data;
};

export const createRule = async (ruleData) => {
  const response = await axios.post(`${API_BASE_URL}/rules`, ruleData, {
    headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
  });
  return response.data;
};

export const updateRule = async (ruleId, ruleData) => {
  const response = await axios.put(`${API_BASE_URL}/rules/${ruleId}`, ruleData, {
    headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
  });
  return response.data;
};

export const deleteRule = async (ruleId) => {
  const response = await axios.delete(`${API_BASE_URL}/rules/${ruleId}`, {
    headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
  });
  return response.data;
};