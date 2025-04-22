import React, { useEffect, useState } from 'react';
import axios from 'axios';
import RuleTable from '../components/RuleTable';

const Dashboard = () => {
  const [rules, setRules] = useState([]);

  useEffect(() => {
    fetchRules();
  }, []);

  const fetchRules = async () => {
    try {
      const response = await axios.get('/rules', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
      });
      setRules(response.data);
    } catch (error) {
      console.error('Failed to fetch rules:', error);
    }
  };

  return (
    <div>
      <h1>Dashboard</h1>
      <RuleTable rules={rules} />
    </div>
  );
};

export default Dashboard;