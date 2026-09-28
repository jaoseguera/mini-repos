"use client";

import { format } from "node:path";
import { useState } from "react";

export default function UserForm() {
    const [name, setName] = useState("");

    const handleSubmit = (e) => {
        e.preventDefault();
        console.log("New user:", name);
        setName("");
    }

    return (
        <form onSubmit={handleSubmit}>
            <input 
                type="text" 
                value={name} 
                onChange={(e) => setName(e.target.value)} 
                placeholder="Enter user name" 
            />
            <button type="submit">Add User</button>
        </form>
    )
}