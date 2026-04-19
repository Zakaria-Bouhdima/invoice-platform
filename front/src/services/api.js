import axios from 'axios';

const http = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

function authHeader(token) {
  return { Authorization: `Bearer ${token}` };
}

export const submitInvoice = (payload, token) =>
  http.post('/invoices', payload, { headers: authHeader(token) }).then((r) => r.data);

export const fetchRules = (clientId, token) =>
  http.get('/rules', { params: { clientId }, headers: authHeader(token) }).then((r) => r.data);

export const createRule = (data, token) =>
  http.post('/rules', data, { headers: authHeader(token) }).then((r) => r.data);

export const updateRule = (ruleId, data, token) =>
  http.put(`/rules/${ruleId}`, data, { headers: authHeader(token) }).then((r) => r.data);

export const deleteRule = (ruleId, token) =>
  http.delete(`/rules/${ruleId}`, { headers: authHeader(token) }).then((r) => r.data);

export const fetchClients = (token) =>
  http.get('/admin/clients', { headers: authHeader(token) }).then((r) => r.data);
