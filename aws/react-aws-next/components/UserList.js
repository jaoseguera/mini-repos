export default function UserList() {
    const users = [
        { id: 1, name: 'Jean' },
        { id: 2, name: 'Marie' },
    ];

    return (
        <div>
            <ul>
                {users.map(user => (
                    <li key={user.id}>{user.name}</li>
                ))}
            </ul>
        </div>
    );
}