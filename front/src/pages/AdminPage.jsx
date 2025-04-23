import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Table } from '../components/RuleTable';

const AdminPage = () => {
  const [clients, setClients] = useState([]);

  useEffect(() => {
    fetchClients();
  }, []);

  const fetchClients = async () => {
    try {
      const response = await axios.get('/admin/clients', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
      });
      setClients(response.data);
    } catch (error) {
      console.error('Failed to fetch clients:', error);
    }
  };

  return (
    <div>
      <h1>Admin Dashboard</h1>
      <Table data={clients} />
    </div>
  );
};

export default AdminPage;