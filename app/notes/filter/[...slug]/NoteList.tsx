// NoteList.tsx
'use client';

import { Note } from '@/types/note';
import css from './NoteList.module.css';

interface NoteListProps {
  notes?: Note[] | null; // тепер може бути undefined або null
}

export function NoteList({ notes }: NoteListProps) {
  // Гарантовано робимо notes масивом
  const safeNotes = Array.isArray(notes) ? notes : [];

  if (safeNotes.length === 0) {
    return <p className={css.empty}>No notes found.</p>;
  }

  return (
    <ul className={css.list}>
      {safeNotes.map((note) => (
        <li key={note.id} className={css.item}>
          <h3 className={css.title}>{note.title}</h3>
          {note.tag && <span className={css.tag}>{note.tag}</span>}
          <p className={css.content}>{note.content}</p>
          <p className={css.date}>{new Date(note.createdAt).toLocaleDateString()}</p>
        </li>
      ))}
    </ul>
  );
}
