#!/bin/bash

echo "🔹 Створюємо структуру проекту та заповнюємо файли..."

# ============================
# 1) @modal
# ============================
mkdir -p app/@modal
mkdir -p "app/@modal/(.)notes/[id]"

# default.tsx
cat > app/@modal/default.tsx <<EOL
export default function Default() {
  return null;
}
EOL

# page.tsx модалки
cat > "app/@modal/(.)notes/[id]/page.tsx" <<EOL
'use client';

import { useParams, useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { fetchNoteById } from '@/lib/api';
import Modal from '@/components/Modal/Modal';
import css from './page.module.css';

export default function NotePreviewModal() {
  const params = useParams();
  const router = useRouter();
  const id = params.id as string;

  const { data: note, isLoading, error } = useQuery({
    queryKey: ['note', id],
    queryFn: () => fetchNoteById(id),
  });

  const handleClose = () => router.back();

  if (isLoading) return <Modal onClose={handleClose}><p>Loading...</p></Modal>;
  if (error || !note) return <Modal onClose={handleClose}><p>Note not found</p></Modal>;

  return (
    <Modal onClose={handleClose}>
      <div className={css.container}>
        <div className={css.item}>
          <div className={css.header}>
            <h2>{note.title}</h2>
            {note.tag && <span className={css.tag}>{note.tag}</span>}
          </div>
          <p className={css.content}>{note.content}</p>
          <p className={css.date}>
            {new Date(note.createdAt).toLocaleDateString()}
          </p>
        </div>
      </div>
    </Modal>
  );
}
EOL

# CSS модалки
cat > "app/@modal/(.)notes/[id]/page.module.css" <<EOL
.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px;
  background-color: #fff;
  border-radius: 8px;
}
.item { display: flex; flex-direction: column; gap: 16px; }
.header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #ddd; padding-bottom: 8px; }
.header h2 { margin: 0; font-size: 28px; color: #333; }
.content { font-size: 18px; line-height: 26px; color: #444; white-space: pre-wrap; }
.date { font-size: 14px; color: #888; text-align: right; }
.tag { display: inline-block; padding: 4px 8px; font-size: 12px; color: #0d6efd; background-color: #e7f1ff; border: 1px solid #b6d4fe; border-radius: 12px; }
EOL

# ============================
# 2) notes/filter
# ============================
mkdir -p app/notes/filter/@sidebar
mkdir -p app/notes/filter/[...slug]

# layout.tsx
cat > app/notes/filter/layout.tsx <<EOL
import { ReactNode } from 'react';
import css from './layout.module.css';

interface FilterLayoutProps {
  sidebar: ReactNode;
  modal: ReactNode;
  children: ReactNode;
}

export default function FilterLayout({ sidebar, modal, children }: FilterLayoutProps) {
  return (
    <>
      <div className={css.container}>
        <aside className={css.sidebar}>{sidebar}</aside>
        <main className={css.notesWrapper}>{children}</main>
      </div>
      {modal}
    </>
  );
}
EOL

cat > app/notes/filter/layout.module.css <<EOL
.container { display: flex; gap: 16px; }
.sidebar { width: 250px; }
.notesWrapper { flex: 1; }
EOL

# sidebar
cat > app/notes/filter/@sidebar/page.tsx <<EOL
'use client';

import Link from 'next/link';
import css from './page.module.css';

const tags = ['all', 'Work', 'Personal', 'Study', 'Other'];

export default function SidebarNotes() {
  return (
    <ul className={css.menuList}>
      {tags.map(tag => (
        <li key={tag} className={css.menuItem}>
          <Link href={tag === 'all' ? '/notes/filter/all' : \`/notes/filter/\${tag}\`} className={css.menuLink}>
            {tag}
          </Link>
        </li>
      ))}
    </ul>
  );
}
EOL

cat > app/notes/filter/@sidebar/page.module.css <<EOL
.menuList { list-style: none; padding: 0; margin: 0; }
.menuItem { margin-bottom: 8px; }
.menuLink { text-decoration: none; color: #0d6efd; }
EOL

# [...slug] page.tsx
cat > app/notes/filter/[...slug]/page.tsx <<EOL
'use client';

import { useParams } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { fetchNotes } from '@/lib/api';
import NoteList from '@/components/NoteList/NoteList';
import SearchBox from '@/components/SearchBox/SearchBox';
import Pagination from '@/components/Pagination/Pagination';
import Modal from '@/components/Modal/Modal';
import NoteForm from '@/components/NoteForm/NoteForm';
import css from './page.module.css';

const PER_PAGE = 12;

export default function FilteredNotesPage() {
  const params = useParams();
  const slug = params.slug as string[];
  const tag = slug?.[0];

  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  const queryTag = tag === 'all' ? undefined : tag;

  const { data, isLoading, error } = useQuery({
    queryKey: ['notes', page, search, queryTag],
    queryFn: () =>
      fetchNotes({ page, perPage: PER_PAGE, search: search || undefined, tag: queryTag }),
  });

  const notes = data?.notes ?? [];
  const totalPages = data?.totalPages ?? 0;

  const handleSearchChange = (value: string) => {
    setSearch(value);
    setPage(1);
  };

  if (isLoading) return <p>Loading notes...</p>;
  if (error) return <p>Error loading notes</p>;

  return (
    <div className={css.app}>
      <div className={css.toolbar}>
        <SearchBox value={search} onChange={handleSearchChange} />
        {totalPages > 1 && <Pagination page={page} totalPages={totalPages} onChange={setPage} />}
        <button type="button" className={css.button} onClick={() => setIsModalOpen(true)}>Create note +</button>
      </div>
      <NoteList notes={notes} />
      {isModalOpen && (
        <Modal onClose={() => setIsModalOpen(false)}>
          <NoteForm onClose={() => setIsModalOpen(false)} />
        </Modal>
      )}
    </div>
  );
}
EOL

cat > app/notes/filter/[...slug]/page.module.css <<EOL
.app { width: 100%; padding: 16px; flex: 1; }
.toolbar { margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center; padding: 16px 0; background-color: #f8f9fa; border-bottom: 1px solid #dee2e6; }
.button { padding: 6px 12px; font-size: 16px; color: #fff; background-color: #0d6efd; border: none; border-radius: 4px; cursor: pointer; transition: background-color 0.2s ease; }
.button:hover { background-color: #0b5ed7; }
EOL

# ============================
# 3) notes page.tsx редірект
# ============================
cat > app/notes/page.tsx <<EOL
import { redirect } from 'next/navigation';

export default function NotesPage() {
  redirect('/notes/filter/all');
}
EOL

# ============================
# 4) not-found
# ============================
mkdir -p app/not-found

cat > app/not-found/page.tsx <<EOL
import css from './page.module.css';

export default function NotFound() {
  return (
    <div className={css.container}>
      <h1 className={css.title}>404 - Page not found</h1>
      <p className={css.description}>Sorry, the page you are looking for does not exist.</p>
    </div>
  );
}
EOL

cat > app/not-found/page.module.css <<EOL
.container { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 80vh; text-align: center; }
.title { font-size: 48px; color: #333; margin-bottom: 16px; }
.description { font-size: 20px; color: #555; }
EOL

echo "✅ Всі файли створені та заповнені!"
